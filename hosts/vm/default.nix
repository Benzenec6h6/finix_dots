{
  vars,
  pkgs,
  ...
}: {
  imports = [
    ./hardware.nix
    ./disko.nix
    #../../modules/core
  ];

  boot.kernelPackages = pkgs.linuxPackages;
  #boot.kernelPackages = pkgs.linuxPackages_6_12;

  virtualisation.qemu.extraArgs = ["-vga" "virtio" "-display" "sdl"];
  virtualisation.diskSize = 4096;

  networking.hostName = vars.host;
  system.stateVersion = vars.version;
}
