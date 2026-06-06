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

# ════════════════════════════════════════════════════════════════
#   PHASE 1 — Gather user information
# ════════════════════════════════════════════════════════════════
get_user_info() {
    logo "Enter Your Account Information"
    # ── Username ─────────────────────────────────────────────
    while true; do
        read -rp "  Username : " USR
        if [[ "${USR}" =~ ^[a-z][a-z0-9_-]{0,30}$ ]]; then
            break
        fi
        printf '  %sInvalid! Lowercase letters, digits, _ or - only. Must start with a letter.%s\n\n' "$RED" "$RST"
    done

    # ── User password ────────────────────────────────────────
    while true; do
        read -rsp "  Password for [${USR}] : " USER_PASSWD; echo
        read -rsp "  Confirm password    : " CONF_USER_PASSWD; echo
        if [[ "$USER_PASSWD" == "$CONF_USER_PASSWD" ]]; then
            printf '  %s✔  User password set%s\n\n' "$GRN" "$RST"
            break
        fi
        printf '  %sPasswords do not match. Try again.%s\n\n' "$RED" "$RST"
    done

    # ── Root password ────────────────────────────────────────
    while true; do
        read -rsp "  ROOT password       : " ROOT_PASSWD; echo
        read -rsp "  Confirm ROOT        : " CONF_ROOT_PASSWD; echo
        if [[ "$ROOT_PASSWD" == "$CONF_ROOT_PASSWD" ]]; then
            printf '  %s✔  Root password set%s\n\n' "$GRN" "$RST"
            break
        fi
        printf '  %sPasswords do not match. Try again.%s\n\n' "$RED" "$RST"
    done

    # ── Hostname ─────────────────────────────────────────────
    while true; do
        read -rp "  Hostname  : " HNAME
        if [[ "$HNAME" =~ ^[a-z]$|^[a-z][a-z0-9_.-]{0,61}[a-z0-9]$ ]]; then
            break
        fi
        printf '  %sInvalid! 1-63 chars, lowercase, digits, - or . only. Cannot start/end with symbols.%s\n\n' "$RED" "$RST"
    done

    clear
}
