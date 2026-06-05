#!/usr/bin/env bash

#  █████╗ ██████╗  ██████╗██╗  ██╗    ██╗███╗   ██╗███████╗████████╗ █████╗ ██╗     ██╗     ███████╗██████╗ 
# ██╔══██╗██╔══██╗██╔════╝██║  ██║    ██║████╗  ██║██╔════╝╚══██╔══╝██╔══██╗██║     ██║     ██╔════╝██╔══██╗
# ███████║██████╔╝██║     ███████║    ██║██╔██╗ ██║███████╗   ██║   ███████║██║     ██║     █████╗  ██████╔╝
# ██╔══██║██╔══██╗██║     ██╔══██║    ██║██║╚██╗██║╚════██║   ██║   ██╔══██║██║     ██║     ██╔══╝  ██╔══██╗
# ██║  ██║██║  ██║╚██████╗██║  ██║    ██║██║ ╚████║███████║   ██║   ██║  ██║███████╗███████╗███████╗██║  ██║
# ╚═╝  ╚═╝╚═╝  ╚═╝ ╚═════╝╚═╝  ╚═╝    ╚═╝╚═╝  ╚═══╝╚══════╝   ╚═╝   ╚═╝  ╚═╝╚══════╝╚══════╝╚══════╝╚═╝  ╚═╝
#   Arch Linux installation script for my personal setups

clear

# ════════════════════════════════════════════════════════════════
#   MACHINE CONSTANTS
# ════════════════════════════════════════════════════════════════
readonly TIMEZONE="Asia/Ho_Chi_Minh"
readonly LOCALE="en_US.UTF-8"
readonly KEYMAP="us"
readonly KERNEL="linux"
readonly CHROOT="arch-chroot /mnt"

# ════════════════════════════════════════════════════════════════
#   COLORS & HELPERS
# ════════════════════════════════════════════════════════════════
RED=$(tput setaf 1)
GRN=$(tput setaf 2)
YLW=$(tput setaf 3)
BLU=$(tput setaf 4)
MGT=$(tput setaf 5)
CYN=$(tput setaf 6)
WHT=$(tput setaf 7)
BOLD=$(tput bold)
RST=$(tput sgr0)

title() {
    local t="${1:?}"
    printf "\n  %s▶ %s%s%s\n" "$BLU" "$YLW" "$t" "$RST"
}

logo() {
    local t="${1:?}"
    clear
    printf '\n'
    printf '  %s%s╔══════════════════════════════════════════════════╗%s\n' "$BOLD" "$BLU" "$RST"
    printf '  %s%s║        Arch Linux — Dell Precision 3551          ║%s\n' "$BOLD" "$BLU" "$RST"
    printf '  %s%s║     i5-10400H (6C/12T) · 16 GB · SSD 256 GB      ║%s\n' "$BOLD" "$BLU" "$RST"
    printf '  %s%s║        Intel UHD 630 · UEFI/GPT · bspwm          ║%s\n' "$BOLD" "$BLU" "$RST"
    printf '  %s%s╚══════════════════════════════════════════════════╝%s\n' "$BOLD" "$BLU" "$RST"
    printf '\n  %s%s▶  %s%s\n\n' "$BLU" "$BOLD" "$t" "$RST"
}

success() {
    printf "\n%s✔  Done%s\n" "$GRN" "$RST"
    sleep 1
}
