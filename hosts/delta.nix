args@{ nixpkgs, home, nur, self, lib, pkgs, system, ... }:

{
  imports =
    [
      ../legacy/delta/configuration.nix
      ../users/root
      ../users/bao
    ];

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot = {
    enable = true;
    configurationLimit = 2;
  };
  boot.loader.efi.canTouchEfiVariables = true;
  boot.cleanTmpDir = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbcore" "sd_mod" "sr_mod" "amdgpu" ];
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-intel" "amdgpu" ];
  boot.extraModulePackages = [ ];
  boot.binfmt.emulatedSystems = [ "armv7l-linux" "aarch64-linux" ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
      options = [ "subvol=nixos" ];
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/CEF4-EDD1";
      fsType = "vfat";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
      options = [ "subvol=home" ];
    };

  fileSystems."/nix" =
    { device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
      options = [ "subvol=nix" ];
    };

  fileSystems."/games" =
    { device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
      options = [ "subvol=games" ];
    };

 #fileSystems."/home/bao/tmp/TopGear" =
 #  { device = "/dev/sda6";
 #    fsType = "ext4";
 #    options = [ "ro" ];
 #  };

  fileSystems."/var/run/btrfs" =
    { device = "/dev/disk/by-uuid/f46f6fe4-c480-49f0-b3fb-22e61c57069c";
      fsType = "btrfs";
      options = [ "subvolid=0" ];
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/86868083-921c-452a-bf78-ae18f26b78bf"; }
    ];

  virtualisation.libvirtd.enable = true;
  virtualisation.virtualbox.host.enable = true;
  virtualisation.anbox.enable = true;

  nix.gc.automatic = true;
  nix.gc.dates = "12:00";
  nix.gc.options = "--delete-older-than 8d";
  nix.optimise.automatic = true;
  nix.optimise.dates = [ "12:30" "00:30" ];
  nix.maxJobs = lib.mkDefault 4;
  powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";

  # Enable bluetooth modules.
  hardware.bluetooth.enable = true;

  programs.vim.defaultEditor = true;

  programs.adb.enable = true;

  services.locate.enable = true;
}