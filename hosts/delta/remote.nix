{ config, lib, pkgs, ... }:

{
  programs.mosh.enable = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    startWhenNeeded = true;
    knownHosts = {
      "Alpha CA" = {
        certAuthority = true;
        hostNames = [ "*" ];
        publicKeyFile = ../../secrets/delta.ssh_host-ca.pub;
      };
      "delta" = {
        hostNames = [ "localhost" "127.0.0.1" "::1" ];
        publicKeyFile = ../../secrets/delta.ssh_host_ed25519_key.pub;
      };
    };
    hostKeys = [
      { bits = 4096; path = "/etc/ssh/ssh_host_rsa_key"; type = "rsa"; }
      { path = "/etc/ssh/ssh_host_ecdsa_key"; type = "ecdsa"; }
      { path = "/etc/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
    ];
    permitRootLogin = "without-password";
    extraConfig = ''
      HostCertificate /etc/ssh/ssh_host_rsa_key-cert.pub
      HostCertificate /etc/ssh/ssh_host_ecdsa_key-cert.pub
      HostCertificate /etc/ssh/ssh_host_ed25519_key-cert.pub
      TrustedUserCAKeys /etc/ssh/ssh_user-ca.pub
      RevokedKeys /etc/ssh/ssh_revoked_keys
      ClientAliveInterval 120
      ClientAliveCountMax 15
    '';
  };

  # Allow all Key Algorithms
  programs.ssh.pubkeyAcceptedKeyTypes = [
    "ssh-ed25519"
    "ssh-ed25519-cert-v01@openssh.com"
    "sk-ssh-ed25519@openssh.com"
    "sk-ssh-ed25519-cert-v01@openssh.com"
    "ssh-rsa"
    "rsa-sha2-256"
    "rsa-sha2-512"
    "ssh-dss"
    "ecdsa-sha2-nistp256"
    "ecdsa-sha2-nistp384"
    "ecdsa-sha2-nistp521"
    "sk-ecdsa-sha2-nistp256@openssh.com"
    "ssh-rsa-cert-v01@openssh.com"
    "rsa-sha2-256-cert-v01@openssh.com"
    "rsa-sha2-512-cert-v01@openssh.com"
    "ssh-dss-cert-v01@openssh.com"
    "ecdsa-sha2-nistp256-cert-v01@openssh.com"
    "ecdsa-sha2-nistp384-cert-v01@openssh.com"
    "ecdsa-sha2-nistp521-cert-v01@openssh.com"
    "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
  ];
  programs.ssh.hostKeyAlgorithms = [
    "ssh-ed25519"
    "ssh-ed25519-cert-v01@openssh.com"
    "sk-ssh-ed25519@openssh.com"
    "sk-ssh-ed25519-cert-v01@openssh.com"
    "ssh-rsa"
    "rsa-sha2-256"
    "rsa-sha2-512"
    "ssh-dss"
    "ecdsa-sha2-nistp256"
    "ecdsa-sha2-nistp384"
    "ecdsa-sha2-nistp521"
    "sk-ecdsa-sha2-nistp256@openssh.com"
    "ssh-rsa-cert-v01@openssh.com"
    "rsa-sha2-256-cert-v01@openssh.com"
    "rsa-sha2-512-cert-v01@openssh.com"
    "ssh-dss-cert-v01@openssh.com"
    "ecdsa-sha2-nistp256-cert-v01@openssh.com"
    "ecdsa-sha2-nistp384-cert-v01@openssh.com"
    "ecdsa-sha2-nistp521-cert-v01@openssh.com"
    "sk-ecdsa-sha2-nistp256-cert-v01@openssh.com"
  ];
}
