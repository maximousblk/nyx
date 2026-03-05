#!/usr/bin/env python3
"""
filter_wallpapers.py — Filter and deduplicate using a continuous Power Law.

Behavior:
  - Scans recursively for images.
  - Filters by Resolution and Orientation (Landscape).
  - Deduplicates using a Power Law based on Image Complexity.
  - Unconditionally logs every file dropped as a duplicate.

Formula:
  Threshold = floor( SCALING_FACTOR * (complexity ^ SCALING_EXPONENT) )

  - OLED/Dark images (Complexity < 5) -> Threshold 0-1 (Strict)
  - Vector/Simple images (Complexity ~20) -> Threshold ~4 (Balanced)
  - Detailed Photos (Complexity > 50) -> Threshold ~7-8 (Standard)
"""

from __future__ import annotations

import argparse
import math
import os
import re
import sys
from concurrent.futures import ProcessPoolExecutor, as_completed
from dataclasses import dataclass
from pathlib import Path

import imagehash
from PIL import Image, ImageStat

# ---------------------------------------------------------------------------
# Constants
# ---------------------------------------------------------------------------

# File Discovery
EXTENSIONS: frozenset[str] = frozenset({".jpg", ".jpeg", ".png", ".webp"})

# Resolution Filters
MIN_WIDTH: int = 1920
MIN_HEIGHT: int = 1080

# Hash Settings
HASH_SIZE: int = 16  # 16x16 = 256 bits. High precision.

# Deduplication Scaling Law (Power Law: y = A * x^B)
# Derived from statistical analysis of the dataset.
SCALING_FACTOR: float = 0.47  # The "A" term
SCALING_EXPONENT: float = 0.67  # The "B" term

# Output Transcoding
JPEG_QUALITY: int = 95  # Pillow JPEG quality (1-95). 90 is visually lossless.

# Safety Limits
MAX_THRESHOLD_CAP: int = 10  # dhash is rarely reliable above 10 bits difference.
MIN_THRESHOLD_FLOOR: int = 0  # Never go below 0.

# ---------------------------------------------------------------------------
# Data Structures
# ---------------------------------------------------------------------------


@dataclass(slots=True)
class ImageInfo:
    path: Path
    width: int
    height: int
    pixels: int
    dhash: imagehash.ImageHash
    complexity: float  # Standard deviation of luminance


# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------


def _normalise_name(path: Path, src_root: Path) -> str:
    """Flatten path to filename: 'dir/subdir/file.jpg' -> 'dir_subdir_file'"""
    try:
        rel = path.relative_to(src_root)
    except ValueError:
        rel = path
    # Replace non-alphanumeric chars with _, strip leading/trailing _
    raw = "_".join(rel.with_suffix("").parts)
    return re.sub(r"[^a-z0-9]+", "_", raw.lower()).strip("_")


def _calculate_dynamic_threshold(complexity: float) -> int:
    """
    Applies the Power Law derived from statistical analysis.
    Threshold = SCALING_FACTOR * (complexity ^ SCALING_EXPONENT)
    """
    if complexity <= 0:
        return MIN_THRESHOLD_FLOOR

    val = SCALING_FACTOR * math.pow(complexity, SCALING_EXPONENT)
    threshold = int(val)

    # Apply safety caps
    return max(MIN_THRESHOLD_FLOOR, min(threshold, MAX_THRESHOLD_CAP))


def _linear_regression(x_vals: list[float], y_vals: list[float]) -> tuple[float, float]:
    """Fits y = mx + c, returns (m, c). Pure Python (no scipy)."""
    n = len(x_vals)
    if n == 0:
        return 0.0, 0.0
    sum_x = sum(x_vals)
    sum_y = sum(y_vals)
    sum_xy = sum(x * y for x, y in zip(x_vals, y_vals))
    sum_xx = sum(x * x for x in x_vals)

    denom = n * sum_xx - sum_x * sum_x
    if denom == 0:
        return 0.0, 0.0

    m = (n * sum_xy - sum_x * sum_y) / denom
    c = (sum_y - m * sum_x) / n
    return m, c


# ---------------------------------------------------------------------------
# Scaling Analysis  (merged from analyze_scaling.py)
# ---------------------------------------------------------------------------


def _print_scaling_stats(images: list[ImageInfo]) -> None:
    """
    Compute nearest-neighbor hamming distances, fit a power law to the
    safety floor, and print a comparison against the configured constants.
    All output goes to stderr — purely informational, nothing is changed.
    """
    n = len(images)
    if n < 2:
        return

    hashes = [int(str(img.dhash), 16) for img in images]
    sigmas = [img.complexity for img in images]

    # --- 1. Nearest-neighbor distances (brute-force O(N²)) ----------------
    print(f"Computing neighbor distances for {n} points...", file=sys.stderr)
    points: list[tuple[float, int]] = []  # (sigma, min_dist)

    for i in range(n):
        my_h = hashes[i]
        min_dist = 999

        for j in range(n):
            if i == j:
                continue
            dist = (my_h ^ hashes[j]).bit_count()
            if dist < min_dist:
                min_dist = dist
            if min_dist == 0:
                break

        # Only keep distinct images (skip exact dupes)
        if min_dist > 0:
            points.append((sigmas[i], min_dist))

    if not points:
        print(
            "  No distinct image pairs found — all are exact duplicates.",
            file=sys.stderr,
        )
        return

    # --- 2. Safety floor (min distance per integer-sigma bucket) -----------
    floor_map: dict[int, int] = {}
    for sigma, dist in points:
        k = int(sigma)
        if k not in floor_map:
            floor_map[k] = dist
        else:
            floor_map[k] = min(floor_map[k], dist)

    floor_x = sorted(floor_map.keys())
    floor_y = [floor_map[x] for x in floor_x]

    # --- 3. Print floor table (every 5th bucket) --------------------------
    print(f"\n{'=' * 60}", file=sys.stderr)
    print(f"{'Sigma':<10} | {'Safety Floor (Min Dist)':<25}", file=sys.stderr)
    print(f"{'=' * 60}", file=sys.stderr)
    for x, y in zip(floor_x[::5], floor_y[::5]):
        print(f"{x:<10} | {y:<25}", file=sys.stderr)
    print(f"{'-' * 60}", file=sys.stderr)

    # --- 4. Fit a power law to the floor (log-log regression) -------------
    log_x = [math.log(x) for x in floor_x if x > 0.5 and floor_map[x] > 0]
    log_y = [math.log(floor_map[x]) for x in floor_x if x > 0.5 and floor_map[x] > 0]

    if len(log_x) > 2:
        b_slope, intercept = _linear_regression(log_x, log_y)
        a_const = math.exp(intercept)

        # Lower 'A' until the curve sits *under* every floor point
        min_adjust = 1.0
        for fx, fy in zip(floor_x, floor_y):
            if fx < 0.5:
                continue
            predicted = a_const * (fx**b_slope)
            if predicted > fy:
                min_adjust = min(min_adjust, fy / predicted)

        fitted_a = a_const * min_adjust * 0.95  # 5 % safety buffer
        fitted_b = b_slope
    else:
        fitted_a, fitted_b = 0.0, 0.0

    # --- 5. Print comparison: fitted model vs. configured constants -------
    print(
        f"\nFitted Power Law  : T = {fitted_a:.4f} * sigma^{fitted_b:.4f}",
        file=sys.stderr,
    )
    print(
        f"Configured Constants: T = {SCALING_FACTOR:.4f} * sigma^{SCALING_EXPONENT:.4f}",
        file=sys.stderr,
    )
    print(f"\nData points (distinct pairs): {len(points)}", file=sys.stderr)

    print(
        f"\n{'Sigma':<10} {'Configured':<12} {'Fitted':<12} {'Act. Floor'}",
        file=sys.stderr,
    )
    for s in (5, 10, 20, 40, 60):
        cfg_val = int(SCALING_FACTOR * math.pow(s, SCALING_EXPONENT))
        fit_val = int(fitted_a * (s**fitted_b)) if fitted_a else 0
        actual = floor_map.get(s, "N/A")
        print(f"{s:<10} {cfg_val:<12} {fit_val:<12} {actual}", file=sys.stderr)

    print(f"{'=' * 60}\n", file=sys.stderr)


# ---------------------------------------------------------------------------
# Worker Function
# ---------------------------------------------------------------------------


def _process_one(filepath: Path) -> ImageInfo | None:
    """Read image, check dims, calc complexity & hash."""
    try:
        with Image.open(filepath) as img:
            width, height = img.size
            if width < MIN_WIDTH or height < MIN_HEIGHT:
                return None
            if height > width:
                return None

            gray = img.convert("L")
            stat = ImageStat.Stat(gray)
            complexity = stat.stddev[0]
            dhash = imagehash.dhash(img, hash_size=HASH_SIZE)

        return ImageInfo(
            path=filepath,
            width=width,
            height=height,
            pixels=width * height,
            dhash=dhash,
            complexity=complexity,
        )
    except Exception:
        return None


# ---------------------------------------------------------------------------
# Deduplication Logic
# ---------------------------------------------------------------------------


def _deduplicate(images: list[ImageInfo], src_root: Path) -> list[ImageInfo]:
    images.sort(key=lambda i: i.pixels, reverse=True)
    kept: list[ImageInfo] = []

    print(f"Deduplicating {len(images)} images...", file=sys.stderr)

    for candidate in images:
        is_dup = False
        cand_threshold = _calculate_dynamic_threshold(candidate.complexity)

        for existing in kept:
            diff = candidate.dhash - existing.dhash
            if diff > MAX_THRESHOLD_CAP:
                continue

            exist_threshold = _calculate_dynamic_threshold(existing.complexity)
            effective_threshold = min(cand_threshold, exist_threshold)

            if diff <= effective_threshold:
                cand_rel_path = candidate.path.relative_to(src_root)
                exist_rel_path = existing.path.relative_to(src_root)
                # Unconditional logging
                print(
                    f"  [DROP] {cand_rel_path} ({candidate.width}x{candidate.height})\n"
                    f"    - Is a duplicate of: {exist_rel_path} ({existing.width}x{existing.height})\n"
                    f"    - Hamming Distance: {diff} (Threshold was {effective_threshold})\n",
                    file=sys.stderr,
                )
                is_dup = True
                break

        if not is_dup:
            kept.append(candidate)

    dropped_count = len(images) - len(kept)
    print(f"Dropped {dropped_count} duplicates.", file=sys.stderr)
    return kept


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------


def _resolve_workers(jobs_arg: int) -> int | None:
    if jobs_arg > 0:
        return jobs_arg
    env = os.environ.get("NIX_BUILD_CORES", "")
    if env.isdigit() and int(env) > 0:
        return int(env)
    return None


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("src", type=Path, help="Source directory")
    parser.add_argument("dst", type=Path, help="Destination directory")
    parser.add_argument("--jobs", "-j", type=int, default=0, help="Max threads")
    args = parser.parse_args()

    candidates = sorted(
        p for p in args.src.rglob("*") if p.is_file() and p.suffix.lower() in EXTENSIONS
    )
    if not candidates:
        print("No images found.", file=sys.stderr)
        return

    max_workers = _resolve_workers(args.jobs)
    print(
        f"Scanning {len(candidates)} files (threads={max_workers or 'auto'})...",
        file=sys.stderr,
    )

    passed: list[ImageInfo] = []
    with ProcessPoolExecutor(max_workers=max_workers) as pool:
        futures = {pool.submit(_process_one, p): p for p in candidates}
        for future in as_completed(futures):
            res = future.result()
            if res:
                passed.append(res)

    print(f"Passed filters (Res/Orientation): {len(passed)}", file=sys.stderr)
    if not passed:
        return

    _print_scaling_stats(passed)

    # Pass src_root for logging purposes
    unique = _deduplicate(passed, src_root=args.src)

    args.dst.mkdir(parents=True, exist_ok=True)
    unique.sort(key=lambda i: str(i.dhash))
    print(
        f"Transcoding {len(unique)} images to JPEG (q={JPEG_QUALITY}) into {args.dst}...",
        file=sys.stderr,
    )

    for info in unique:
        norm = _normalise_name(info.path, args.src)
        dest_name = f"{info.dhash}_{norm}.jpg"
        dest_path = args.dst / dest_name
        with Image.open(info.path) as img:
            img = img.convert("RGB")  # Drop alpha / palette for JPEG compat
            img.save(dest_path, format="JPEG", quality=JPEG_QUALITY, subsampling=0)
        dest_path.chmod(0o444)


if __name__ == "__main__":
    main()
