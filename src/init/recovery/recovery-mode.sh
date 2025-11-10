#!/bin/bash
# Aether OS Recovery Mode
# Minimal boot environment for system recovery

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Print banner
print_banner() {
    clear
    cat << 'EOF'
╔════════════════════════════════════════╗
║                                        ║
║        AETHER OS RECOVERY MODE         ║
║                                        ║
╚════════════════════════════════════════╝

EOF
}

# Recovery menu
show_menu() {
    echo -e "${BLUE}Recovery Options:${NC}"
    echo ""
    echo "  1) Restart System Services"
    echo "  2) Repair Filesystem"
    echo "  3) Restore from Backup"
    echo "  4) Factory Reset"
    echo "  5) View System Logs"
    echo "  6) Open Shell"
    echo "  7) Reboot"
    echo "  8) Power Off"
    echo ""
    echo -n "Select option [1-8]: "
}

# Restart services
restart_services() {
    echo -e "${BLUE}Restarting system services...${NC}"
    echo ""

    if [ -x /usr/bin/aether-service-manager ]; then
        /usr/bin/aether-service-manager restart
    else
        systemctl restart aether-power.service
        systemctl restart aether-network.service
        systemctl restart aether-audio.service
        systemctl restart aether-display.service
    fi

    echo ""
    echo -e "${GREEN}Services restarted${NC}"
    sleep 2
}

# Repair filesystem
repair_filesystem() {
    echo -e "${BLUE}Checking and repairing filesystems...${NC}"
    echo ""

    # Unmount and check /data
    if mountpoint -q /data; then
        umount /data
    fi

    if [ -b /dev/mmcblk0p3 ]; then
        echo "Checking /data partition..."
        fsck -y /dev/mmcblk0p3 || true
        mount /dev/mmcblk0p3 /data
    fi

    echo ""
    echo -e "${GREEN}Filesystem check complete${NC}"
    sleep 2
}

# Restore from backup
restore_backup() {
    echo -e "${BLUE}Restore from Backup${NC}"
    echo ""

    local backup_dir="/data/backups"

    if [ ! -d "$backup_dir" ]; then
        echo -e "${RED}No backups found${NC}"
        sleep 2
        return
    fi

    echo "Available backups:"
    ls -lh "$backup_dir"
    echo ""

    echo -n "Enter backup filename (or 'cancel'): "
    read backup_file

    if [ "$backup_file" = "cancel" ]; then
        return
    fi

    if [ ! -f "$backup_dir/$backup_file" ]; then
        echo -e "${RED}Backup file not found${NC}"
        sleep 2
        return
    fi

    echo ""
    echo -e "${YELLOW}WARNING: This will restore system to backup state${NC}"
    echo -n "Continue? (yes/no): "
    read confirm

    if [ "$confirm" != "yes" ]; then
        echo "Cancelled"
        sleep 1
        return
    fi

    echo ""
    echo "Restoring from backup..."
    tar -xzf "$backup_dir/$backup_file" -C / || true

    echo ""
    echo -e "${GREEN}Restore complete${NC}"
    sleep 2
}

# Factory reset
factory_reset() {
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo -e "${RED}         FACTORY RESET WARNING        ${NC}"
    echo -e "${RED}═══════════════════════════════════════${NC}"
    echo ""
    echo "This will:"
    echo "  - Erase all user data"
    echo "  - Remove all installed applications"
    echo "  - Reset all settings to defaults"
    echo ""
    echo -e "${RED}THIS CANNOT BE UNDONE!${NC}"
    echo ""
    echo -n "Type 'RESET' to confirm: "
    read confirm

    if [ "$confirm" != "RESET" ]; then
        echo "Cancelled"
        sleep 1
        return
    fi

    echo ""
    echo "Performing factory reset..."
    echo ""

    # Wipe /data partition
    if mountpoint -q /data; then
        umount /data
    fi

    if [ -b /dev/mmcblk0p3 ]; then
        echo "Formatting /data..."
        mkfs.ext4 -F /dev/mmcblk0p3
        mount /dev/mmcblk0p3 /data
    fi

    # Clear cache
    if [ -d /cache ]; then
        rm -rf /cache/*
    fi

    # Reset system configuration
    if [ -d /etc/aetheros ]; then
        cp -r /etc/aetheros.defaults/* /etc/aetheros/ 2>/dev/null || true
    fi

    echo ""
    echo -e "${GREEN}Factory reset complete${NC}"
    echo ""
    echo "System will reboot in 5 seconds..."
    sleep 5
    reboot
}

# View logs
view_logs() {
    echo -e "${BLUE}System Logs${NC}"
    echo ""
    echo "1) Boot log"
    echo "2) System log"
    echo "3) Service log"
    echo "4) Kernel log"
    echo "5) Back"
    echo ""
    echo -n "Select log [1-5]: "
    read log_choice

    case "$log_choice" in
        1)
            less /var/log/aether-startup.log
            ;;
        2)
            less /var/log/syslog
            ;;
        3)
            less /var/log/aether-service-manager.log
            ;;
        4)
            dmesg | less
            ;;
        5)
            return
            ;;
    esac
}

# Open shell
open_shell() {
    echo -e "${BLUE}Opening recovery shell...${NC}"
    echo "Type 'exit' to return to recovery menu"
    echo ""
    /bin/bash
}

# Main loop
main() {
    print_banner

    while true; do
        show_menu
        read choice

        echo ""

        case "$choice" in
            1)
                restart_services
                ;;
            2)
                repair_filesystem
                ;;
            3)
                restore_backup
                ;;
            4)
                factory_reset
                ;;
            5)
                view_logs
                ;;
            6)
                open_shell
                ;;
            7)
                echo "Rebooting..."
                reboot
                ;;
            8)
                echo "Powering off..."
                poweroff
                ;;
            *)
                echo -e "${RED}Invalid option${NC}"
                sleep 1
                ;;
        esac

        print_banner
    done
}

main "$@"
