{ ... }:
{
  services.resolved.enable = false;

  services.dnscrypt-proxy = {
    enable = true;
    upstreamDefaults = true;
    settings = {
      # DoH only — runs over port 443, looks like normal HTTPS traffic
      doh_servers = true;
      dnscrypt_servers = false;
      odoh_servers = false;

      server_names = [
        "cloudflare"
        "cloudflare-ipv6"
      ];

      require_dnssec = true;
      require_nolog = true;
      require_nofilter = true;

      # Bypass Airtel's resolver for initial server list fetch
      ignore_system_dns = true;
      bootstrap_resolvers = [
        "9.9.9.11:53"
        "8.8.8.8:53"
      ];

      # Route queries through relay nodes so Cloudflare can't correlate
      # your IP with your queries
      anonymized_dns = {
        routes = [
          {
            server_name = "cloudflare";
            via = [
              "anon-cs-singapore"
              "dnscry.pt-anon-fujairah-ipv4"
            ];
          }
          {
            server_name = "cloudflare-ipv6";
            via = [
              "anon-cs-singapore6"
              "dnscry.pt-anon-fujairah-ipv6"
            ];
          }
        ];
      };
    };
  };

  networking.nameservers = [
    "127.0.0.1"
    "::1"
  ];
}
