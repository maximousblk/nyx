{
  lib,
  buildNpmPackage,
  fetchFromGitHub,
  jq,
}:
let
  package = buildNpmPackage {
  pname = "pi-mcp-adapter";
  version = "2.21.1-unstable-20260808";

  src = fetchFromGitHub {
    owner = "nicobailon";
    repo = "pi-mcp-adapter";
    rev = "7dfe06899279832dd320a7c228e48e8a9f503807";
    hash = "sha256-voO8gCDjGtXoSiEQM/D4lL4JXrz5be3HZ5ol7KYVCzI=";
  };

  npmDepsHash = "sha256-A5LZ0KJpM/0RBVwquLZe6Xy1RQ2z+tNYFrWqnmTbhfY=";
  dontNpmBuild = true;
  npmInstallFlags = [ "--ignore-scripts" ];
  nativeBuildInputs = [ jq ];

  postPatch = ''
    substituteInPlace config.ts \
      --replace-fail \
        'return overridePath ? resolve(overridePath) : getAgentPath("mcp.json");' \
        'return overridePath ? resolve(overridePath) : join(homedir(), ".config", "mcp", "mcp_private.json");'

    ${jq}/bin/jq '
      del(.packages[""].devDependencies)
      | .packages |= with_entries(select(.key | startswith("node_modules/@earendil-works/pi-coding-agent") | not))
    ' package-lock.json > package-lock.json.tmp
    mv package-lock.json.tmp package-lock.json

    ${jq}/bin/jq 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/pi-mcp-adapter
    cp -r . $out/pi-mcp-adapter/

    runHook postInstall
  '';

  meta = {
    description = "Token-efficient MCP adapter for Pi and OMP";
    homepage = "https://github.com/nicobailon/pi-mcp-adapter";
    license = lib.licenses.mit;
    platforms = lib.platforms.all;
  };
  };
in
{
  inherit package;
  extension = "${package}/pi-mcp-adapter/index.ts";
}
