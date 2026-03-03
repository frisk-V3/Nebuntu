#!/bin/bash
set -e

# 1. 必要なツールのインストール
sudo apt-get update
sudo apt-get install -y xorriso squashfs-tools wget mtools libpapi-dev

# 2. Ubuntu 24.04 LTS のダウンロード (URLを正確に指定)
ISO_URL="https://releases.ubuntu.com"
wget "$ISO_URL" -O base.iso

# 3. ISOを解凍
mkdir -p source
xorriso -osirrox on -indev base.iso -extract / source/

# 4. rootfs (filesystem.squashfs) を解凍
mkdir -p rootfs
sudo unsquashfs -d rootfs source/casper/filesystem.squashfs

# 5. 【改造】 ネットワーク設定とマウント (chrootで通信するために必須)
sudo cp /etc/resolv.conf rootfs/etc/resolv.conf
sudo mount --bind /dev rootfs/dev
sudo mount --bind /proc rootfs/proc
sudo mount --bind /sys rootfs/sys

# 6. 【改造実行】 chroot内部での作業
sudo chroot rootfs bash -c "
  export DEBIAN_FRONTEND=noninteractive
  
  # issue / motd の書き換え
  echo 'Nubuntu 1.0 (Custom)' > /etc/issue
  echo 'Welcome to Nubuntu - The Ultimate Dev OS' > /etc/motd

  # VS Code リポジトリ追加とインストール
  apt-get update && apt-get install -y wget gpg apt-transport-https
  wget -qO- https://packages.microsoft.com | gpg --dearmor > /usr/share/keyrings/microsoft.gpg
  echo 'deb [arch=amd64 signed-by=/usr/share/keyrings/microsoft.gpg] https://packages.microsoft.com stable main' > /etc/apt/sources.list.d/vscode.list
  
  apt-get update
  apt-get install -y code firefox git vim curl

  # キャッシュ削除 (ISOを軽くするため)
  apt-get clean
  rm -rf /var/lib/apt/lists/*
"

# 7. 後片付け (アンマウント)
sudo umount rootfs/dev
sudo umount rootfs/proc
sudo umount rootfs/sys

# 8. filesystem.squashfs の再構築
sudo rm source/casper/filesystem.squashfs
sudo mksquashfs rootfs source/casper/filesystem.squashfs -comp xz

# 9. 新しいISOの作成 (モダンなUEFI/BIOS両対応フラグ)
# ※ source/boot/grub/i386-pc/eltorito.img のパスは24.04の構造に合わせる必要があります
sudo xorriso -as mkisofs -r \
  -V "Nubuntu_1.0" \
  -o nubuntu.iso \
  -J -joliet-long -l \
  -b boot/grub/i386-pc/eltorito.img \
  -c boot.catalog \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot \
  -e boot/grub/efi.img \
  -no-emul-boot \
  -isohybrid-gpt-basdat \
  source/

echo "完了！ nubuntu.iso が生成されました。"
