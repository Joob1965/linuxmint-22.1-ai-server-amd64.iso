# Rebuilding the ISO

## Windows with WSL

Install Ubuntu or Debian under WSL, then inside WSL:

```bash
sudo apt update
sudo apt install -y xorriso isolinux syslinux-utils
cd /mnt/d/ISO/Linux\ eigenebau/linuxmint-22.1-cinnamon-64bit
bash build-ai-server-iso.sh /mnt/d/path/to/linuxmint-22.1-cinnamon-64bit.iso
```

The script:

1. extracts the official Linux Mint ISO;
2. adds the AI server preseed and post-install scripts;
3. adds BIOS and UEFI boot menu entries;
4. creates the hybrid boot ISO;
5. writes an MD5 checksum.

The source ISO, generated ISO, and build work directory are excluded from normal Git history.
