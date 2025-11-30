# btrfs/disko-config.nix

{
  disks ? [ "/dev/sda" ],
  ...
}:
let
  number_of_disks =
    if (builtins.length disks < 3) then
      builtins.length disks
    else
      throw "Error. Too many disks passed to disko.";
in
{
  disko.devices = {
    disk = {
      main-disk = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "500M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            swap = {
              size = "8G";
              content = {
                type = "swap";
                randomEncryption = true;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [ "-f" ]; # Override existing partition
                subvolumes = {
                  "@" = { };
                  "@/root" = {
                    mountpoint = "/";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/home" = {
                    mountpoint = "/home";
                    mountOptions = [ "compress=zstd" ];
                  };
                  "@/nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/persist" = {
                    mountpoint = "/persist";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/var-lib" = {
                    mountpoint = "/var/lib";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/var-log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                  "@/var-tmp" = {
                    mountpoint = "/var/tmp";
                    mountOptions = [
                      "compress=zstd"
                      "noatime"
                    ];
                  };
                };
              };
            };
          };
        };
      };

      # vdb =
      # if (number_of_disks == 1) then
      #   { }
      # else
      #   {
      #     type = "disk";
      #     device = builtins.elemAt disks 1;
      #     content = {
      #       type = "gpt";
      #       partitions = {
      #         DATA = {
      #           # name = "DATA";
      #           start = "1MiB";
      #           end = "100%";
      #           content = {
      #             type = "btrfs";
      #             extraArgs = [ "-f" ]; # Override existing partition
      #             subvolumes = {
      #               "@" = {
      #                 mountpoint = "/DATA";
      #                 mountOptions = [
      #                   "compress=zstd"
      #                   "noatime"
      #                 ];
      #               };
      #               "@/home" = {
      #                 mountpoint = "/home";
      #                 mountOptions = [ "compress=zstd" ];
      #               };
      #             };
      #           };
      #         };
      #       };
      #     };
      #   };
    };
  };
}
