{
  config,
  pkgs,
  ...
}: {
  # 1. Finixが用意してくれているLimineブートローダーを有効化
  programs.limine.enable = true;

  # 2. EFI環境用の一般的な設定（実機へのインストール時にも役立ちます）
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot"; # パーティション構成に合わせて調整

  # 3. 必要に応じてLimineのメニュータイムアウトなどを設定（お好みで）
  programs.limine.settings = {
    timeout = 5;
  };
}
