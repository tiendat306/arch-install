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

display_logo () {
	printf "
                        $BLU.
                       $BLU/ $MGT\\
                      $BLU/   $MGT\\
                     $BLU/^.   $MGT\\
                    $BLU/  .$WHT-$MGT.  \\
                   $BLU/  (   $MGT) _\\
                  $BLU/ _.~   $MGT~._^\\
                 $BLU/.^         $MGT^.\\

	"
    printf "$RED󰮯   $CYN   $YLW󰊠   $WHT   $MGT󰊠   $GRN   $BLU󰊠   $RED   $WHT󰮯\n"
}

info_msg() {
    printf '\n\n%s%s[%s %s%s %s%s %s%s]%s\n\n' "${BOLD}" "${RED}" "${RST}" "${BOLD}" "${BLU}" "${1:?}" "${RST}" "${BOLD}" "${RED}" "${RST}"
}
processing_msg() {
    printf '%s%s → %s %s\n' "${BOLD}" "${WHT}" "${1:?}" "${RST}"
}
success_msg() {
    printf '%s%s ▶ %s %s\n' "${BOLD}" "${GRN}" "${1:?}" "${RST}"
}
warning_msg() {
    printf '%s%s%s %s\n' "${BOLD}" "${YLW}" "${1:?}" "${RST}"
}
error_msg() {
    printf '%s%s[ERROR]: %s %s\n' "${BOLD}" "${RED}" "${1:?}" "${RST}" >&2
}

# ════════════════════════════════════════════════════════════════
#   0 — Pre-flight checks
# ════════════════════════════════════════════════════════════════
run_preflight_checks() {
    display_logo

    # ── Check internet connection ────────────────────────
    info_msg "Check internet connection"
    
    while ! ping -c 1 archlinux.org &>/dev/null; do
        error_msg "No internet connection detected."
        printf '  1) Connect to WiFi (open iwctl)\n'
        printf '  2) Retry connection check (e.g., after plugging ethernet)\n'
        printf '  3) Exit installation\n\n'
        read -rp " Select an option (1-3): " net_opt
        
        case "$net_opt" in
            1)
                processing_msg "Launching iwctl..."
                sleep 1
                iwctl
                ;;
            2)
                processing_msg "Retrying ping..."
                sleep 1
                ;;
            3|*)
                warning_msg "Exit installation"
                exit 1
                ;;
        esac
    done
    
    success_msg "Internet connection verified successfully."
    sleep 2

    # ── Check Boot mode ────────────────────────────────────────
    info_msg "Check Boot mode"
    if [ ! -d /sys/firmware/efi/efivars ]; then
        error_msg "This script requires UEFI mode."
        error_msg "Boot the USB in UEFI mode (check BIOS settings)."
        printf '\n'
        read -rp "Press ENTER to exit..."
        exit 1
    fi
    success_msg "UEFI boot mode verified successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   1 — Gather user information
# ════════════════════════════════════════════════════════════════
get_user_info() {
    display_logo
    info_msg "User Accounts & System Configuration"

    # ── Hostname ─────────────────────────────────────────────
    warning_msg "Please enter the system hostname"
    while true; do
        read -rp " - Hostname : " HNAME
        if [[ "$HNAME" =~ ^[a-z]$|^[a-z][a-z0-9_.-]{0,61}[a-z0-9]$ ]]; then
            printf '\n'
            break
        fi
        error_msg "Invalid hostname! Must be 1-63 chars, lowercase letters, digits, - or ., and cannot start/end with symbols."
        printf '\n'
    done
    # ── Root password ────────────────────────────────────────
    warning_msg "Please set the ROOT (administrator) password"
    while true; do
        read -rsp " - ROOT password : " ROOT_PASSWD; echo
        read -rsp " - Confirm ROOT password : " CONF_ROOT_PASSWD; echo
        if [[ "$ROOT_PASSWD" == "$CONF_ROOT_PASSWD" ]]; then
            success_msg "Password configured successfully for root."
            printf '\n'
            break
        fi
        error_msg "Passwords do not match. Try again."
        printf '\n'
    done

    # ── Username ─────────────────────────────────────────────
    warning_msg "Please enter a username for your personal account"
    while true; do
        read -rp " - Username : " USR
        if [[ "${USR}" =~ ^[a-z][a-z0-9_-]{0,30}$ ]]; then
            printf '\n'
            break
        fi
        error_msg "Invalid username! Must start with a lowercase letter and contain only a-z, 0-9, _ or - (max 32 chars)."
        printf '\n'
    done

    # ── User password ────────────────────────────────────────
    warning_msg "Please set the password for user [${USR}]"
    while true; do
        read -rsp " - User password : " USER_PASSWD; echo
        read -rsp " - Confirm user password : " CONF_USER_PASSWD; echo
        if [[ "$USER_PASSWD" == "$CONF_USER_PASSWD" ]]; then
            success_msg "Password configured successfully for user [${USR}]."
            printf '\n'
            break
        fi
        error_msg "Passwords do not match. Try again."
        printf '\n'
    done
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   2 — Disk selection
# ════════════════════════════════════════════════════════════════
select_disk() {
    display_logo
    info_msg "Select installation disk"

    printf '  Available disks:\n\n'
    lsblk -d -e 7,11 -o NAME,SIZE,TYPE,MODEL
    printf '\n─────────────────────────────────────────────────────\n\n'

    warning_msg "Please choose the installation disk"
    PS3="→ Selection (number) : "
    select DRIVE in $(lsblk -dnp -e 7,11 -o NAME); do
        if [[ -n "$DRIVE" && -b "$DRIVE" ]]; then
            success_msg "Selected installation disk: $DRIVE."
            break
        else
            error_msg "Invalid selection! Please choose a valid disk number from the list."
            printf '\n'
        fi
    done
    sleep 2
    clear
}

# ════════════════════════════════════════════════════════════════
#   3 — Partitioning, formatting and mounting
# ════════════════════════════════════════════════════════════════
select_partition() {
    local drive="${1:?}"
    local label="${2:?}"           # "EFI" or "Root"
    local type_desc="${3:?}"       # "EFI System" or "Linux filesystem"
    local gpt_uuid="${4:?}"        # GPT partition type UUID
    local -n out_var="${5:?}"      # nameref pointing to return variable (e.g. EFI_PART or ROOT_PART)

    while true; do
        info_msg "Select ${label} partition"
        lsblk "${drive}" -o NAME,SIZE,FSTYPE,PARTTYPENAME
        printf '\n'

        local part_list
        part_list=$(lsblk -lnp -o NAME,PARTTYPE "${drive}" | awk -v gpt="${gpt_uuid}" '$2==gpt{print $1}')

        if [[ -z "$part_list" ]]; then
            error_msg "No ${type_desc} partition found!"
            warning_msg "Please re-partition and set Type to \"${type_desc}\""
            warning_msg "Press ENTER to open cfdisk again..."
            read -r
            cfdisk "${drive}"
            
            # Force kernel to reread partition table and wait for udev to populate device nodes (prevents detection lag)
            partprobe "${drive}" 2>/dev/null || partx -u "${drive}" 2>/dev/null || true
            udevadm settle 2>/dev/null || true
            continue
        fi
    
        local part_arr=($part_list)
        if [[ ${#part_arr[@]} -eq 1 ]]; then
            out_var="${part_arr[0]}"
            success_msg "Automatically selected ${label} partition: ${out_var}."
            sleep 2
            break
        else
            PS3="  → Choose ${label} partition: "
            select choice in $part_list; do
                if [[ -n "$choice" ]]; then
                    out_var="${choice}"
                    success_msg "Selected ${label} partition: ${out_var}."
                    sleep 1
                    break 2
                fi
            done
        fi
    done
}

partition_and_mount() {
    display_logo
    info_msg "Partitioning disk"

    printf '  %s Recommended GPT layout for %s:%s\n\n' "$YLW" "$DRIVE" "$RST"
    printf '  ┌────────────────────────────────────────────────────────┐\n'
    printf '  │  Partition 1 :  512 MB       Type: EFI System          │\n'
    printf '  │  Partition 2 :  Remaining    Type: Linux filesystem    │\n'
    printf '  └────────────────────────────────────────────────────────┘\n\n'
    warning_msg 'cfdisk will open now. Create the layout above, then "Write" and "Quit"'
    warning_msg 'Press ENTER to continue...'
    read -r

    cfdisk "${DRIVE}"
    
    # Force kernel to reread partition table and wait for udev to populate device nodes (prevents detection lag)
    partprobe "${DRIVE}" 2>/dev/null || partx -u "${DRIVE}" 2>/dev/null || true
    udevadm settle 2>/dev/null || true

    # ── Select EFI partition ─────────────────────────────────
    select_partition "${DRIVE}" "EFI" "EFI System" "c12a7328-f81f-11d2-ba4b-00a0c93ec93b" EFI_PART

    # ── Select Root partition ────────────────────────────────
    select_partition "${DRIVE}" "Root" "Linux filesystem" "0fc63daf-8483-4772-8e79-3d69d8477de4" ROOT_PART

    # ── Format & mount ───────────────────────────────────────
    info_msg "Formatting & Mounting Partitions"

    processing_msg "Formatting EFI partition (${EFI_PART}) as FAT32"
    mkfs.fat -F32 "${EFI_PART}" >/dev/null || { error_msg "Format EFI failed!"; exit 1; }

    processing_msg "Formatting Root partition (${ROOT_PART}) as ext4 (label: ArchLinux)"
    mkfs.ext4 -L ArchLinux "${ROOT_PART}" >/dev/null || { error_msg "Format Root failed!"; exit 1; }

    processing_msg "Mounting partitions"
    mount -t ext4 "${ROOT_PART}" /mnt || { error_msg "Mount Root failed!"; exit 1; }
    mkdir -p /mnt/efi
    mount "${EFI_PART}" /mnt/efi || { error_msg "Mount EFI failed!"; exit 1; }

    printf '\n'
    success_msg "${ROOT_PART} mounted at /mnt"
    success_msg "${EFI_PART} mounted at /mnt/efi"
    success_msg "All partitions formatted and mounted successfully."
    warning_msg 'Press ENTER to continue...'
    read -r
    
    clear
}

# ════════════════════════════════════════════════════════════════
#   MAIN — Execution order
# ════════════════════════════════════════════════════════════════
run_preflight_checks

get_user_info

select_disk
partition_and_mount
