{ inputs, config, lib, pkgs, system, hosts, ... }:

{
  imports = [
    ../../profiles/meta/fatal-warnings.nix
    ../../profiles/misc/disable-mitigations.nix
    ../../profiles/misc/udev-nosettle.nix
    ../../profiles/misc/adblocking.nix
    ../../profiles/security/sudo.nix
    ../../profiles/networking/ipfs
    ../../profiles/networking/bluetooth
    ../../profiles/networking/wireguard
    ../../profiles/networking/mdns.nix
    ../../profiles/sound/pulse.nix
    ../../profiles/graphical
    ../../profiles/wayland.nix
    ../../profiles/weechat.nix
    ../../users/root.nix
    ../../users/bao.nix
    ./xserver.nix
    ./network.nix
    ./remote.nix
  ];

  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    efi.canTouchEfiVariables = true;
    systemd-boot = {
      enable = true;
      configurationLimit = 16;
    };
  };
  boot.plymouth.enable = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" "amdgpu" "fuse" ];
  boot.extraModulePackages = with config.boot.kernelPackages; [ v4l2loopback ];
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  fileSystems = let
    btrfs = {
      device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
    };
  in {
    "/" = btrfs // { options = [ "subvol=nixos" ]; };
    "/home" = btrfs // { options = [ "subvol=home" ]; };
    "/nix" = btrfs // { options = [ "subvol=nix" ]; };
    "/games" = btrfs // { options = [ "subvol=games" ]; };
    "/var/run/btrfs" = btrfs // { options = [ "subvolid=0" ]; };

    "/boot" = {
      device = "/dev/disk/by-uuid/CEF4-EDD1";
      fsType = "vfat";
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-uuid/86868083-921c-452a-bf78-ae18f26b78bf"; }
  ];

  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = false;
  virtualisation.anbox.enable = builtins.trace "Anbox still disabled until nixos/nixpkgs#91367 is resolved" false;
  systemd.network.networks = {
    "40-anbox0".networkConfig.ConfigureWithoutCarrier = true;
  };

  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  nix = {
    gc.automatic = true;
    gc.dates = "12:00";
    gc.options = "--delete-older-than 8d";

    autoOptimiseStore = false; # Disabled for speed
    optimise.automatic = true;
    optimise.dates = [ "17:30" "02:00" ];
  };

  hardware.ckb-next.enable = true;
  hardware.opengl.driSupport32Bit = true;
  hardware.cpu = {
    intel.updateMicrocode = true;
    amd.updateMicrocode = true;
  };

  programs.firejail = {
    enable = true;
    wrappedBinaries = {
      chromium-safe = "${lib.getBin pkgs.large.chromium}/bin/chromium";
      firefox-safe = "${lib.getBin pkgs.large.firefox}/bin/firefox";
      mpv-safe = "${lib.getBin pkgs.mpv}/bin/mpv";
    };
  };
  programs.vim.defaultEditor = true;
  programs.adb.enable = true;
  programs.tmux.enable = true;
  programs.xonsh.enable = true;

  services.disnix.enable = true;
  services.printing.enable = true;
  services.nix-index.enable = true;
  services.locate.enable = true;
  services.pcscd.enable = true;
  services.guix.enable = true;
  services.guix.package = pkgs.guix;
  services.nixos-git = {
    enable = false;
    github = { owner = "bqv"; repo = "nixos"; };
    branch = "live";
    extraParams = {
      idle_fetch_timeout = 10;
    };
  };
  services.flatpak.enable = true;
  xdg.portal.enable = true;

  nix.buildMachines = lib.optionals true [
    {
      hostName = hosts.wireguard.zeta;
      #sshUser = "nix-ssh";
      sshKey = "/etc/nix/id_zeta.ed25519";
      #system = "x86_64-linux";
      systems = ["x86_64-linux" "i686-linux" "armv6l-linux" "armv7l-linux"];
      maxJobs = 4;
      speedFactor = 4;
      supportedFeatures = [ "nixos-test" "benchmark" "big-parallel" "kvm" ];
      mandatoryFeatures = [ ];
    }
  ];
  nix.distributedBuilds = true;
  nix.extraOptions = ''
    builders-use-substitutes = true
  '';

  environment.systemPackages = with pkgs; [
    clipmenu bitwarden bitwarden-cli pass protonmail-bridge

    ckb-next riot-desktop nheko discord ripcord
    qutebrowser firefox fx_cast_bridge
    thunderbird electronmail mpv apvlv

    dunst catt termite rxvt_unicode
    steam obs-studio

    anbox #pmbootstrap

    (with hunspellDicts; hunspellWithDicts [ en_GB-large ])
    wineWowPackages.staging
  ];
  nixpkgs.config.firefox.enableFXCastBridge = true;

  system.extraSystemBuilderCmds = ''
    ln -s '${inputs.self.nixosConfigurations.zeta.config.system.build.toplevel}' "$out/zeta"
  '';
}
