{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.services.infiniter.websupportDDNS;
  recordArgs = lib.concatMapStringsSep " " lib.escapeShellArg cfg.records;

  updater = pkgs.writeShellApplication {
    name = "websupport-ddns";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      gnugrep
      jq
      openssl
    ];
    text = ''
      set -euo pipefail

      : "''${WEBSUPPORT_API_KEY:?WEBSUPPORT_API_KEY is not set}"
      : "''${WEBSUPPORT_API_SECRET:?WEBSUPPORT_API_SECRET is not set}"

      api="https://rest.websupport.sk"
      zone=${lib.escapeShellArg cfg.zone}
      current_ip="$(curl -4 -fsS --max-time 20 ${lib.escapeShellArg cfg.ipv4Url})"

      if ! grep -Eq '^([0-9]{1,3}\.){3}[0-9]{1,3}$' <<< "$current_ip"; then
        echo "Invalid public IPv4 address: $current_ip" >&2
        exit 1
      fi

      request() {
        local method="$1"
        local path="$2"
        local data="''${3:-}"
        local timestamp signature date_header

        timestamp="$(date -u +%s)"
        signature="$(printf '%s' "$method $path $timestamp" | openssl dgst -sha1 -hmac "$WEBSUPPORT_API_SECRET" -r | cut -d ' ' -f 1)"
        date_header="$(date -u -d "@$timestamp" +"%Y%m%dT%H%M%SZ")"

        if [[ -n "$data" ]]; then
          curl -fsS \
            -X "$method" \
            -H "Date: $date_header" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -u "$WEBSUPPORT_API_KEY:$signature" \
            -d "$data" \
            "$api$path"
        else
          curl -fsS \
            -X "$method" \
            -H "Date: $date_header" \
            -H "Accept: application/json" \
            -H "Content-Type: application/json" \
            -u "$WEBSUPPORT_API_KEY:$signature" \
            "$api$path"
        fi
      }

      records_path="/v1/user/self/zone/$zone/record"
      records_json="$(request GET "$records_path")"

      for record in ${recordArgs}; do
        matching_records="$(jq -c --arg name "$record" '.items[] | select(.type == "A" and .name == $name)' <<< "$records_json")"

        if [[ -z "$matching_records" ]]; then
          data="$(jq -n --arg name "$record" --arg content "$current_ip" --argjson ttl ${toString cfg.ttl} '{type: "A", name: $name, content: $content, ttl: $ttl}')"
          request POST "$records_path" "$data" >/dev/null
          echo "Created $record.$zone A record with $current_ip"
          continue
        fi

        while IFS= read -r dns_record; do
          record_id="$(jq -r '.id' <<< "$dns_record")"
          record_content="$(jq -r '.content' <<< "$dns_record")"

          if [[ "$record_content" == "$current_ip" ]]; then
            echo "$record.$zone already points to $current_ip"
            continue
          fi

          data="$(jq -n --arg name "$record" --arg content "$current_ip" --argjson ttl ${toString cfg.ttl} '{name: $name, content: $content, ttl: $ttl}')"
          request PUT "$records_path/$record_id" "$data" >/dev/null
          echo "Updated $record.$zone from $record_content to $current_ip"
        done <<< "$matching_records"
      done
    '';
  };
in {
  options.services.infiniter.websupportDDNS = {
    enable = lib.mkEnableOption "Websupport dynamic DNS updater";

    zone = lib.mkOption {
      type = lib.types.str;
      example = "example.com";
      description = "DNS zone to update in Websupport.";
    };

    records = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      example = ["www" "status"];
      description = "A record names inside the zone that should point to this host's public IPv4 address.";
    };

    ttl = lib.mkOption {
      type = lib.types.ints.positive;
      default = 600;
      description = "TTL for created or updated DNS records.";
    };

    interval = lib.mkOption {
      type = lib.types.str;
      default = "5min";
      description = "How often to check and update Websupport DNS records.";
    };

    credentialsFile = lib.mkOption {
      type = lib.types.path;
      default = "/var/lib/websupport-ddns/credentials.env";
      description = "Environment file containing WEBSUPPORT_API_KEY and WEBSUPPORT_API_SECRET.";
    };

    ipv4Url = lib.mkOption {
      type = lib.types.str;
      default = "https://api.ipify.org";
      description = "URL used to discover the current public IPv4 address.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.records != [];
        message = "services.infiniter.websupportDDNS.records must contain at least one record.";
      }
    ];

    systemd.services.websupport-ddns = {
      description = "Update Websupport DNS records for the current public IP";
      after = ["network-online.target"];
      wants = ["network-online.target"];

      serviceConfig = {
        Type = "oneshot";
        ExecStart = "${updater}/bin/websupport-ddns";
        EnvironmentFile = cfg.credentialsFile;
        StateDirectory = "websupport-ddns";
        UMask = "0077";
        NoNewPrivileges = true;
        PrivateTmp = true;
        ProtectHome = true;
        ProtectSystem = "strict";
        RestrictAddressFamilies = ["AF_INET" "AF_INET6" "AF_UNIX"];
      };
    };

    systemd.timers.websupport-ddns = {
      description = "Run Websupport dynamic DNS updater";
      wantedBy = ["timers.target"];
      timerConfig = {
        OnBootSec = "1min";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
      };
    };
  };
}
