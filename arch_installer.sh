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
#   0 — Pre-flight checks
# ════════════════════════════════════════════════════════════════
check_internet() {
    logo "Checking Internet connection"
    
    while ! ping -c 1 archlinux.org &>/dev/null; do
        printf '\n  %sERROR: No internet connection detected.%s\n\n' "$RED" "$RST"
        printf '  1) Connect to WiFi (open iwctl)\n'
        printf '  2) Retry connection check (e.g., after plugging ethernet)\n'
        printf '  3) Exit installation\n\n'
        read -rp "  Select an option (1-3): " net_opt
        
        case "$net_opt" in
            1)
                printf '\n  %sLaunching iwctl... Use "exit" to return to the installer after connecting.%s\n' "$YLW" "$RST"
                sleep 2
                iwctl
                ;;
            2)
                printf '\n  Retrying ping...\n'
                sleep 1
                ;;
            3|*)
                printf '\n  Exiting installer.\n\n'
                exit 1
                ;;
        esac
    done
    
    printf '  %s✔  Internet OK%s\n' "$GRN" "$RST"
    sleep 1
    clear
}

check_uefi() {
    logo "Checking Boot Mode"
    if [ ! -d /sys/firmware/efi/efivars ]; then
        printf '\n  %sERROR: This script requires UEFI mode.\n' "$RED"
        printf '  Boot the USB in UEFI mode (check BIOS settings).%s\n\n' "$RST"
        exit 1
    fi
    printf '  %s✔  UEFI mode confirmed%s\n' "$GRN" "$RST"
    sleep 1
    clear
}

# ════════════════════════════════════════════════════════════════
#   1 — Gather user information
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

# ════════════════════════════════════════════════════════════════
#   2 — Disk selection
# ════════════════════════════════════════════════════════════════
select_disk() {
    logo "Select Installation Disk"

    printf '  Available disks:\n\n'
    lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
    printf '\n  ─────────────────────────────────────────────────────\n\n'

    PS3="  → Choose disk (number): "
    select DRIVE in $(lsblk -dnp -e 7,11 -o NAME); do
        [[ -n "$DRIVE" && -b "$DRIVE" ]] && break
    done
    
    clear
}

# ════════════════════════════════════════════════════════════════
#   3 — Partitioning, formatting and mounting
# ════════════════════════════════════════════════════════════════
partition_and_mount() {
    logo "Partitioning Disk"

    printf '  %sRecommended GPT layout for %s:%s\n\n' "$YLW" "$DRIVE" "$RST"
    printf '  ┌────────────────────────────────────────────────────────┐\n'
    printf '  │  Partition 1 :  512 MB       Type: EFI System          │\n'
    printf '  │  Partition 2 :  Remaining    Type: Linux filesystem    │\n'
    printf '  └────────────────────────────────────────────────────────┘\n\n'
    printf '  cfdisk will open now. Create the layout above, then "Write" and "Quit".\n'
    printf '  Press ENTER to continue...\n'
    read -r

    cfdisk "${DRIVE}"
    partx -u "${DRIVE}" 2>/dev/null || true   # refresh kernel partition table

    # ── Select EFI partition ─────────────────────────────────
    while true; do
        logo "Select EFI Partition"
        lsblk "${DRIVE}" -o NAME,SIZE,PARTTYPENAME
        printf '\n'

        local efi_list
        efi_list=$(lsblk -lnp -o NAME,PARTTYPE "${DRIVE}" | awk '$2=="c12a7328-f81f-11d2-ba4b-00a0c93ec93b"{print $1}')

        if [[ -z "$efi_list" ]]; then
            printf '  %sERROR: No EFI System partition found!%s\n' "$RED" "$RST"
            printf '  Please re-partition and set Type to "EFI System".\n'
            printf '  Press ENTER to open cfdisk again...\n'
            read -r
            cfdisk "${DRIVE}"
            partx -u "${DRIVE}" 2>/dev/null || true
            continue
        fi
    
        local efi_arr=($efi_list)
        if [[ ${#efi_arr[@]} -eq 1 ]]; then
            EFI_PART="${efi_arr[0]}"
            printf '  %sAutomatically selected EFI partition: %s%s\n' "$GRN" "$EFI_PART" "$RST"
            sleep 1
            break
        else
            PS3="  → Choose EFI partition: "
            select EFI_PART in $efi_list; do
                [[ -n "$EFI_PART" ]] && break 2
            done
        fi
    done

    # ── Select Root partition ────────────────────────────────
    while true; do
        logo "Select Root Partition"
        lsblk "${DRIVE}" -o NAME,SIZE,FSTYPE,PARTTYPENAME
        printf '\n'

        local root_list
        root_list=$(lsblk -lnp -o NAME,PARTTYPE "${DRIVE}" | awk '$2=="0fc63daf-8483-4772-8e79-3d69d8477de4"{print $1}')

        if [[ -z "$root_list" ]]; then
            printf '  %sERROR: No Linux filesystem partition found!%s\n' "$RED" "$RST"
            printf '  Please re-partition and set Type to "Linux filesystem".\n'
            printf '  Press ENTER to open cfdisk again...\n'
            read -r
            cfdisk "${DRIVE}"
            partx -u "${DRIVE}" 2>/dev/null || true
            continue
        fi
    
        local root_arr=($root_list)
        if [[ ${#root_arr[@]} -eq 1 ]]; then
            ROOT_PART="${root_arr[0]}"
            printf '  %sAutomatically selected Root partition: %s%s\n' "$GRN" "$ROOT_PART" "$RST"
            sleep 1
            break
        else
            PS3="  → Choose Root partition: "
            select ROOT_PART in $root_list; do
                [[ -n "$ROOT_PART" ]] && break 2
            done
        fi
    done

    # ── Format & mount ───────────────────────────────────────
    logo "Formatting & Mounting Partitions"

    title "Formatting EFI  →  FAT32"
    mkfs.fat -F32 "${EFI_PART}" >/dev/null || { printf '%sFormat EFI failed!%s\n' "$RED" "$RST"; exit 1; }

    title "Formatting Root →  ext4  (label: ArchLinux)"
    mkfs.ext4 -L ArchLinux "${ROOT_PART}" >/dev/null || { printf '%sFormat Root failed!%s\n' "$RED" "$RST"; exit 1; }

    title "Mounting Partitions"
    mount "${ROOT_PART}" /mnt || { printf '%sMount Root failed!%s\n' "$RED" "$RST"; exit 1; }
    mkdir -p /mnt/efi
    mount "${EFI_PART}" /mnt/efi || { printf '%sMount EFI failed!%s\n' "$RED" "$RST"; exit 1; }

    printf '\n  %s%-10s%s mounted at /mnt\n' "$GRN" "$ROOT_PART" "$RST"
    printf '  %s%-10s%s mounted at /mnt/efi\n' "$GRN" "$EFI_PART" "$RST"
    success
    sleep 3
    
    clear
}

# ════════════════════════════════════════════════════════════════
#   MAIN — Execution order
# ════════════════════════════════════════════════════════════════
check_internet
check_uefi

get_user_info

select_disk
partition_and_mount
