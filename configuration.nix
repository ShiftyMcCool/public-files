{
  config,
  lib,
  pkgs,
  ...
}:
let
  impermanence = builtins.fetchTarball {
    url = "https://github.com/nix-community/impermanence/archive/master.tar.gz";
  };
in
{
  boot = {
    # kernelParams = [ "quiet" "loglevel=3" ];
    kernelParams = [ "quiet" ];
    loader = {
      grub = { 
          enable = true;
          devices = [ "nodev" ];
          efiSupport = true;
          efiInstallAsRemovable = true;
      };
      timeout = 3;
    };
  };

  imports = [ 
    ./hardware-configuration.nix
   "${builtins.fetchTarball "https://github.com/nix-community/disko/archive/master.tar.gz"}/module.nix"
    ./disko-config.nix
    #"${impermanence}/nixos.nix"
    #./impermanence.nix
  ];

  environment.systemPackages = with pkgs; [
    git
  ];

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQDWAHZ07y/ome3ioXmlQpWP+7NsY9+UKG8/AT0pCgB macbook"
    ];
  };

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
    };
    hostKeys = [
      {
        path = "/etc/ssh/forgejo";
        type = "ed25519";
      }
    ];
  };

  programs.ssh = {
    extraConfig = "
      Host forgejo
        HostName forgejo.it-clowd.top
        Port 2223
        User git
        IdentityFile /etc/ssh/forgejo
        IdentitiesOnly yes
    ";
  };

  system.stateVersion = "25.05";
}
