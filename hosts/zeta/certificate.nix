{ config, lib, pkgs, domains, ... }:

let
  inherit (lib) genAttrs const nameValuePair;

  email = "ssl+${config.networking.hostName}@${domains.home}";
  mkCertFor = domain: rec {
    inherit email;
    allowKeysForGroup = true;
    #directory = "/var/lib/acme/${domain}/";
    #domain = domain;
    extraDomains = genAttrs [
      "*.${domain}"
    ] (const null);
    group = "keys";

    dnsProvider = "cloudflare";
    credentialsFile = "/etc/ssl/${dnsProvider}";
    dnsPropagationCheck = true;
  };
in {
  security.acme = {
    certs = genAttrs (builtins.attrValues domains) mkCertFor;
  };

  systemd.services.haproxy.serviceConfig = lib.mkIf config.services.haproxy.enable {
    SupplementaryGroups = "keys";
  };
}
