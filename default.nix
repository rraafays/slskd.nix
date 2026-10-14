{
  config,
  pkgs,
  lib,
  ...
}:

let
  user = config.common.username;
  cfg = config.services.slskdStack;
in
{
  options.services.slskdStack = {
    enable = lib.mkEnableOption "Soulseek (slskd) and Transmission download stack";
    downloadPath = lib.mkOption {
      type = lib.types.str;
      default = "/away/main/Downloads";
      description = "Shared download directory for slskd and Transmission.";
    };
    environmentFile = lib.mkOption {
      type = lib.types.str;
      default = "/etc/slskd/env";
      description = "Environment file for slskd (host should provide via secrets).";
    };
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open slskd firewall ports (5030/tcp and udp).";
    };
  };

  config = lib.mkIf cfg.enable {
    users.groups.downloads = { };

    users.users.${user} = {
      extraGroups = lib.mkAfter [ "downloads" ];
    };

    users.users.slskd.extraGroups = [ "downloads" ];
    users.users.transmission.extraGroups = [ "downloads" ];

    networking.firewall.allowedTCPPorts = lib.mkAfter [ 5030 ];
    networking.firewall.allowedUDPPorts = lib.mkAfter [ 5030 ];

    services.transmission = {
      enable = true;
      openRPCPort = true;
      openFirewall = true;
      settings = {
        rpc-bind-address = "0.0.0.0";
        rpc-whitelist = "*";
        download-dir = cfg.downloadPath;
      };
    };

    services.slskd = {
      enable = true;
      openFirewall = cfg.openFirewall;
      environmentFile = cfg.environmentFile;
      settings = {
        web.authentication.disabled = true;
        directories.downloads = cfg.downloadPath;
      };
    };

    systemd.tmpfiles.rules = [
      "d ${cfg.downloadPath} 2775 ${user} downloads -"
    ];

    systemd.services.transmission.serviceConfig.UMask = lib.mkForce "0002";
    systemd.services.slskd.serviceConfig.UMask = lib.mkForce "0002";
  };
}
