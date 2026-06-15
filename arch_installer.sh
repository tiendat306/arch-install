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
#   4 — Install base system
# ════════════════════════════════════════════════════════════════

install_base_system() {
    display_logo
    info_msg "Install base system"
    
    processing_msg "Configuring pacman (color, parallel downloads)..."
    sed -i \
        's/#Color/Color/;
         s/#ParallelDownloads = 5/ParallelDownloads = 5/;
         /^ParallelDownloads =/a ILoveCandy' \
        /etc/pacman.conf
    sleep 1

    processing_msg "Updating pacman mirrors via reflector (VN/SG/JP)..."
    reflector --verbose --latest 10 \
              --country "Vietnam,Singapore,Japan" \
              --sort rate \
              --save /etc/pacman.d/mirrorlist >/dev/null 2>&1
    sleep 1

    processing_msg "Running pacstrap to install base packages..."
    sleep 1
    pacstrap /mnt \
        base base-devel \
        "${KERNEL}" linux-firmware intel-ucode \
        mkinitcpio \
        networkmanager \
        reflector \
        zsh git vim \
        zram-generator

    success_msg "Base system packages installed successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   5 — Generate fstab
# ════════════════════════════════════════════════════════════════
gen_fstab() {
    display_logo
    info_msg "Generate fstab"
    
    genfstab -U /mnt >> /mnt/etc/fstab
    success_msg "fstab generated and written to /mnt/etc/fstab successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   6 — Configure localization
# ════════════════════════════════════════════════════════════════

configure_localization() {
    display_logo
    info_msg "Configure localization"
    
    # Set the timezone and sync the hardware clock
    processing_msg "Setting timezone to ${TIMEZONE}..."
    $CHROOT ln -sf "/usr/share/zoneinfo/${TIMEZONE}" /etc/localtime
    $CHROOT hwclock --systohc
    sleep 1

    # Configure locales (enable specified locale and generate it)
    processing_msg "Configuring locales (${LOCALE})..."
    echo "${LOCALE} UTF-8" >> /mnt/etc/locale.gen
    $CHROOT locale-gen >/dev/null
    echo "LANG=${LOCALE}" > /mnt/etc/locale.conf
    sleep 1

    # Configure keyboard layout and console font
    processing_msg "Setting console keyboard layout to ${KEYMAP}..."
    printf 'KEYMAP=%s\nFONT=Lat2-Terminus16\n' "$KEYMAP" > /mnt/etc/vconsole.conf
    sleep 1
    
    success_msg "Localization configured successfully."
    sleep 2
    
    clear
}

# ════════════════════════════════════════════════════════════════
#   7 — Configure network identity
# ════════════════════════════════════════════════════════════════

configure_network_identity() {
    display_logo
    info_msg "Configure network identity"

    # Set system hostname and configure /etc/hosts
    processing_msg "Setting hostname to ${HNAME} and configuring hosts..."
    echo "${HNAME}" > /mnt/etc/hostname
    cat >> /mnt/etc/hosts <<- EOL
		127.0.0.1   localhost
		::1         localhost
		127.0.1.1   ${HNAME}.localdomain ${HNAME}
	EOL
    success_msg "Network identity configured successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   8 — Create user accounts
# ════════════════════════════════════════════════════════════════
create_users() {
    display_logo
    info_msg "Create user accounts"

    # Set root password
    processing_msg "Configuring password for root administrator..."
    echo "root:${ROOT_PASSWD}" | $CHROOT chpasswd
    sleep 1

    # Create personal user account and add to essential groups
    processing_msg "Creating user account [${USR}] with wheel, audio, video, storage groups..."
    $CHROOT useradd -m -g users -G wheel,audio,video,storage -s /usr/bin/zsh "${USR}"
    echo "${USR}:${USER_PASSWD}" | $CHROOT chpasswd
    sleep 1

    # Configure sudo privileges: temporarily allow wheel group group members to run sudo without password
    # (used during installation, will be reverted before final reboot)
    processing_msg "Configuring temporary NOPASSWD sudo privileges for wheel group..."
    sed -i \
        's/# %wheel ALL=(ALL:ALL) NOPASSWD: ALL/%wheel ALL=(ALL:ALL) NOPASSWD: ALL/' \
        /mnt/etc/sudoers
    echo 'Defaults insults' >> /mnt/etc/sudoers
    sleep 1

    success_msg "User accounts and passwords configured successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   9 — Install GRUB bootloader
# ════════════════════════════════════════════════════════════════
install_grub() {
    display_logo
    info_msg "Install GRUB Bootloader"

    # Install GRUB and other bootloader utilities
    processing_msg "Installing grub, efibootmgr, and os-prober packages..."
    $CHROOT pacman -S grub efibootmgr os-prober --noconfirm >/dev/null
    sleep 1

    # Install GRUB onto the EFI partition
    processing_msg "Installing GRUB bootloader to /efi (UEFI)..."
    $CHROOT grub-install \
        --target=x86_64-efi \
        --efi-directory=/efi \
        --bootloader-id=ArchLinux
    sleep 1

    # Configure GRUB settings (disable watchdog, optimizations, enable os-prober)
    processing_msg "Optimizing /etc/default/grub settings..."
    sed -i \
        's/quiet/nowatchdog mitigations=off zswap.enabled=0 transparent_hugepage=madvise/;
         s/#GRUB_DISABLE_OS_PROBER/GRUB_DISABLE_OS_PROBER/' \
        /mnt/etc/default/grub
    sleep 1

    # Load GPU kernel modules early in initramfs for early Kernel Mode Setting (KMS)
    processing_msg "Adding i915 module to /etc/mkinitcpio.conf..."
    sed -i "s/MODULES=()/MODULES=(i915)/" /mnt/etc/mkinitcpio.conf
    sleep 1

    # Regenerate initramfs images for the new kernel setup
    processing_msg "Regenerating initramfs images (mkinitcpio)..."
    $CHROOT mkinitcpio -P
    sleep 1

    # Generate GRUB configuration file
    processing_msg "Generating grub.cfg..."
    echo
    $CHROOT grub-mkconfig -o /boot/grub/grub.cfg
    sleep 1

    success_msg "GRUB bootloader installed and configured successfully."
    sleep 2

    clear
}

# ════════════════════════════════════════════════════════════════
#   MAIN — Execution order
# ════════════════════════════════════════════════════════════════
run_preflight_checks

get_user_info

select_disk
partition_and_mount

install_base_system
gen_fstab
configure_localization
configure_network_identity
create_users
install_grub
