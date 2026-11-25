#!/usr/bin/env bash
set -euo pipefail

SOURCE_ISO="${1:-}"
OUTPUT_ISO="${2:-linuxmint-22.1-ai-server-amd64.iso}"
WORK_DIR="${WORK_DIR:-build-work}"

if [[ -z "$SOURCE_ISO" ]]; then
  echo "Usage: $0 <linuxmint-22.1-cinnamon-64bit.iso> [output.iso]"
  exit 2
fi

command -v xorriso >/dev/null || { echo "xorriso is required"; exit 1; }
command -v isohybrid >/dev/null || { echo "isohybrid is required"; exit 1; }

rm -rf "$WORK_DIR"
mkdir -p "$WORK_DIR"
xorriso -osirrox on -indev "$SOURCE_ISO" -extract / "$WORK_DIR/tree"

install -m 0644 config/preseed.cfg "$WORK_DIR/tree/preseed.cfg"
install -m 0755 config/post-install.sh "$WORK_DIR/tree/post-install.sh"
install -m 0755 config/01-install-ollama.sh "$WORK_DIR/tree/01-install-ollama.sh"

python3 - <<'PY'
from pathlib import Path

live = Path("build-work/tree/isolinux/live.cfg")
text = live.read_text()
entry = """label ai-server
\tmenu label Install AI Server (automatic)
\tkernel /casper/vmlinuz
\tappend boot=casper initrd=/casper/initrd.lz username=joachim hostname=ai-server automatic-ubiquity ubiquity/quick-install=true preseed/file=/cdrom/preseed.cfg quiet splash --

"""
if "label ai-server" not in text:
    text = text.replace("label live\n", entry + "label live\n")
live.write_text(text)

grub = Path("build-work/tree/boot/grub/grub.cfg")
text = grub.read_text()
entry = """menuentry "Install AI Server (automatic)" --class linuxmint {
\tset gfxpayload=keep
\tlinux\t/casper/vmlinuz boot=casper username=joachim hostname=ai-server automatic-ubiquity ubiquity/quick-install=true preseed/file=/cdrom/preseed.cfg quiet splash --
\tinitrd\t/casper/initrd.lz
}
"""
if "Install AI Server" not in text:
    text = text.replace('menuentry "Start Linux Mint', entry + 'menuentry "Start Linux Mint', 1)
grub.write_text(text)
PY

xorriso -as mkisofs -r -V "LINUXMINTAISERVER" -J -joliet-long -l \
  -iso-level 3 -partition_offset 16 \
  -b isolinux/isolinux.bin -c isolinux/boot.cat \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  -eltorito-alt-boot -e boot/grub/efi.img -no-emul-boot \
  -o "$OUTPUT_ISO" "$WORK_DIR/tree"

isohybrid -u "$OUTPUT_ISO"
md5sum "$OUTPUT_ISO" | tee "${OUTPUT_ISO}.md5"
