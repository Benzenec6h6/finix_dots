{
  config,
  pkgs,
  vars,
  ...
}: {
  # Home Managerを一旦置いておいた、純粋なシステムユーザー定義

  users.users.${vars.user.name} = {
    isNormalUser = true;
    description = "Main user";

    # Finix側（default.nix）に最初から用意されている安全なグループだけを指定
    extraGroups = ["wheel" "audio" "video" "input" "kvm"];

    password = vars.user.passwd;
    shell = pkgs.zsh;
  };

  # Finix側のデフォルトシェルをzshに変えたい場合はここも有効
  users.defaultUserShell = pkgs.zsh;
}
