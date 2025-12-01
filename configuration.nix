{
  config,
  lib,
  pkgs,
  ...
}:

{
  boot.loader.grub.enable = true;
  boot.loader.grub.device = "/dev/sda";
  boot.loader.grub.useOSProber = true;

  imports = [ ./hardware-configuration.nix ];

  environment.systemPackages = with pkgs; [
    git
  ];

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDQDWAHZ07y/ome3ioXmlQpWP+7NsY9+UKG8/AT0pCgB macbook"
    ];
  };

  programs.git = {
    enable = true;
    userName = "Ryan Harris";
    userEmail = "ryan@it-clowd.top";
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
