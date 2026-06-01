{
  vars,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./disko.nix
    ../../modules/core
  ];

  boot.kernelPackages = pkgs.linuxPackages;
  #boot.kernelPackages = pkgs.linuxPackages_6_12;

  networking.hostName = vars.host;
}
