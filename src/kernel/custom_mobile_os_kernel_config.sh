#!/bin/bash

# Custom Mobile OS Kernel Configuration Script
# For Linux Kernel 6.16.x
# Optimized for non-Android mobile operating systems

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Kernel source directory
KERNEL_DIR="${KERNEL_DIR:-/home/user/linux}"
CONFIG_FILE="${KERNEL_DIR}/.config"
BACKUP_DIR="${KERNEL_DIR}/config_backups"

# Function to print colored messages
print_msg() {
    echo -e "${GREEN}[✓]${NC} $1"
}

print_error() {
    echo -e "${RED}[✗]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[!]${NC} $1"
}

print_info() {
    echo -e "${BLUE}[i]${NC} $1"
}

# Create backup of existing config
create_backup() {
    mkdir -p "$BACKUP_DIR"
    if [ -f "$CONFIG_FILE" ]; then
        local backup_file="$BACKUP_DIR/.config.$(date +%Y%m%d_%H%M%S)"
        cp "$CONFIG_FILE" "$backup_file"
        print_msg "Backup created: $backup_file"
    fi
}

# Initialize configuration
init_config() {
    cd "$KERNEL_DIR"
    
    if [ ! -f "$CONFIG_FILE" ]; then
        print_info "No existing config found. Creating default config..."
        make defconfig
    fi
    
    create_backup
}

# Use kernel's config script
config_enable() {
    if [ -f "$KERNEL_DIR/scripts/config" ]; then
        "$KERNEL_DIR/scripts/config" --enable "$1" 2>/dev/null || true
    else
        echo "CONFIG_$1=y" >> "$CONFIG_FILE"
    fi
}

config_disable() {
    if [ -f "$KERNEL_DIR/scripts/config" ]; then
        "$KERNEL_DIR/scripts/config" --disable "$1" 2>/dev/null || true
    else
        echo "# CONFIG_$1 is not set" >> "$CONFIG_FILE"
    fi
}

config_module() {
    if [ -f "$KERNEL_DIR/scripts/config" ]; then
        "$KERNEL_DIR/scripts/config" --module "$1" 2>/dev/null || true
    else
        echo "CONFIG_$1=m" >> "$CONFIG_FILE"
    fi
}

config_set_val() {
    if [ -f "$KERNEL_DIR/scripts/config" ]; then
        "$KERNEL_DIR/scripts/config" --set-val "$1" "$2" 2>/dev/null || true
    else
        echo "CONFIG_$1=$2" >> "$CONFIG_FILE"
    fi
}

config_set_str() {
    if [ -f "$KERNEL_DIR/scripts/config" ]; then
        "$KERNEL_DIR/scripts/config" --set-str "$1" "$2" 2>/dev/null || true
    else
        echo "CONFIG_$1=\"$2\"" >> "$CONFIG_FILE"
    fi
}

# Core System Configuration
configure_core_system() {
    print_info "Configuring Core System Features..."
    
    # Essential system features
    config_enable SYSVIPC
    config_enable POSIX_MQUEUE
    config_enable CROSS_MEMORY_ATTACH
    config_enable USELIB
    config_enable AUDIT
    config_enable AUDITSYSCALL
    
    # High resolution timers (essential for mobile)
    config_enable HIGH_RES_TIMERS
    config_enable NO_HZ_IDLE
    config_enable NO_HZ_FULL
    config_enable NO_HZ
    config_enable TICK_CPU_ACCOUNTING
    
    # CPU hotplug for power management
    config_enable HOTPLUG_CPU
    config_enable SCHED_MC
    config_enable SCHED_SMT
    
    # Process management
    config_enable TASKSTATS
    config_enable TASK_XACCT
    config_enable TASK_IO_ACCOUNTING
    config_enable PSI
    config_enable PSI_DEFAULT_DISABLED
    
    # Control Groups (for resource management)
    config_enable CGROUPS
    config_enable CGROUP_FREEZER
    config_enable CGROUP_PIDS
    config_enable CGROUP_DEVICE
    config_enable CPUSETS
    config_enable PROC_PID_CPUSET
    config_enable CGROUP_CPUACCT
    config_enable CGROUP_PERF
    config_enable CGROUP_SCHED
    config_enable FAIR_GROUP_SCHED
    config_enable RT_GROUP_SCHED
    config_enable CGROUP_BPF
    config_enable MEMCG
    config_enable MEMCG_SWAP
    config_enable BLK_CGROUP
    config_enable CGROUP_WRITEBACK
    
    # Namespaces (for containers/isolation)
    config_enable NAMESPACES
    config_enable UTS_NS
    config_enable IPC_NS
    config_enable USER_NS
    config_enable PID_NS
    config_enable NET_NS
    config_enable CGROUP_NS
    config_enable TIME_NS
    
    # IPC
    config_enable SYSVIPC
    config_enable POSIX_MQUEUE
    config_enable WATCH_QUEUE
    
    # Kernel features
    config_enable RELAY
    config_enable BLK_DEV_INITRD
    config_enable KALLSYMS
    config_enable KALLSYMS_ALL
    config_enable PRINTK
    config_enable BUG
    config_enable ELF_CORE
    config_enable BASE_FULL
    config_enable FUTEX
    config_enable EPOLL
    config_enable SIGNALFD
    config_enable TIMERFD
    config_enable EVENTFD
    config_enable SHMEM
    config_enable AIO
    config_enable IO_URING
    config_enable ADVISE_SYSCALLS
    config_enable MEMBARRIER
    
    # Loadable module support
    config_enable MODULES
    config_enable MODULE_UNLOAD
    config_enable MODULE_FORCE_UNLOAD
    config_enable MODVERSIONS
    config_enable MODULE_SRCVERSION_ALL
    
    print_msg "Core system features configured"
}

# Power Management Configuration
configure_power_management() {
    print_info "Configuring Advanced Power Management..."
    
    # Core PM
    config_enable PM
    config_enable PM_SLEEP
    config_enable PM_SLEEP_SMP
    config_enable PM_AUTOSLEEP
    config_enable PM_WAKELOCKS
    config_set_val PM_WAKELOCKS_LIMIT 200
    config_enable PM_WAKELOCKS_GC
    config_enable PM_RUNTIME
    config_enable PM_GENERIC_DOMAINS
    config_enable PM_GENERIC_DOMAINS_SLEEP
    config_enable PM_GENERIC_DOMAINS_OF
    
    # Suspend/Hibernation
    config_enable SUSPEND
    config_enable SUSPEND_FREEZER
    config_enable HIBERNATION
    config_enable PM_STD_PARTITION
    
    # CPU Frequency Scaling
    config_enable CPU_FREQ
    config_enable CPU_FREQ_STAT
    config_enable CPU_FREQ_DEFAULT_GOV_SCHEDUTIL
    config_enable CPU_FREQ_GOV_PERFORMANCE
    config_enable CPU_FREQ_GOV_POWERSAVE
    config_enable CPU_FREQ_GOV_USERSPACE
    config_enable CPU_FREQ_GOV_ONDEMAND
    config_enable CPU_FREQ_GOV_CONSERVATIVE
    config_enable CPU_FREQ_GOV_SCHEDUTIL
    
    # CPU Idle
    config_enable CPU_IDLE
    config_enable CPU_IDLE_GOV_LADDER
    config_enable CPU_IDLE_GOV_MENU
    config_enable CPU_IDLE_GOV_TEO
    config_enable CPU_IDLE_GOV_HALTPOLL
    
    # Energy Model
    config_enable ENERGY_MODEL
    
    # Thermal Management
    config_enable THERMAL
    config_enable THERMAL_NETLINK
    config_enable THERMAL_STATISTICS
    config_enable THERMAL_EMERGENCY_POWEROFF_DELAY_MS
    config_enable THERMAL_HWMON
    config_enable THERMAL_OF
    config_enable THERMAL_WRITABLE_TRIPS
    config_enable THERMAL_GOV_FAIR_SHARE
    config_enable THERMAL_GOV_STEP_WISE
    config_enable THERMAL_GOV_BANG_BANG
    config_enable THERMAL_GOV_USER_SPACE
    config_enable THERMAL_GOV_POWER_ALLOCATOR
    config_enable CPU_THERMAL
    config_enable CPU_FREQ_THERMAL
    config_enable DEVFREQ_THERMAL
    
    # Power capping
    config_enable POWERCAP
    config_enable IDLE_INJECT
    
    # Wake sources debugging
    config_enable PM_SLEEP_DEBUG
    config_enable PM_ADVANCED_DEBUG
    
    # Work queue power efficiency
    config_enable WQ_POWER_EFFICIENT_DEFAULT
    
    print_msg "Power management configured"
}

# Memory Management Configuration
configure_memory_management() {
    print_info "Configuring Memory Management..."
    
    # Compressed memory
    config_enable ZSWAP
    config_enable ZSWAP_DEFAULT_ON
    config_enable ZPOOL
    config_enable ZBUD
    config_enable Z3FOLD
    config_enable ZSMALLOC
    config_enable ZSMALLOC_STAT
    config_enable ZRAM
    config_enable ZRAM_WRITEBACK
    config_enable ZRAM_MEMORY_TRACKING
    
    # Memory optimization
    config_enable SWAP
    config_enable KSM
    config_enable DEFAULT_MMAP_MIN_ADDR
    config_set_val DEFAULT_MMAP_MIN_ADDR 32768
    config_enable MEMORY_FAILURE
    config_enable TRANSPARENT_HUGEPAGE
    config_enable TRANSPARENT_HUGEPAGE_ALWAYS
    config_enable CLEANCACHE
    config_enable FRONTSWAP
    
    # Low memory killer (custom implementation needed)
    config_enable MEMCG
    config_enable MEMCG_SWAP
    config_enable MEMCG_KMEM
    
    # Memory compaction
    config_enable COMPACTION
    config_enable COMPACT_UNEVICTABLE_DEFAULT
    
    # Page reporting
    config_enable PAGE_REPORTING
    
    # Memory hotplug (for advanced memory management)
    config_enable MEMORY_HOTPLUG
    config_enable MEMORY_HOTPLUG_DEFAULT_ONLINE
    config_enable MEMORY_HOTREMOVE
    
    # CMA for graphics/camera buffers
    config_enable CMA
    config_enable DMA_CMA
    config_set_val CMA_SIZE_MBYTES 256
    
    print_msg "Memory management configured"
}

# Storage and Filesystem Configuration
configure_storage() {
    print_info "Configuring Storage and Filesystems..."
    
    # Block layer
    config_enable BLOCK
    config_enable BLK_DEV_LOOP
    config_set_val BLK_DEV_LOOP_MIN_COUNT 16
    config_enable BLK_DEV_RAM
    config_set_val BLK_DEV_RAM_COUNT 16
    config_set_val BLK_DEV_RAM_SIZE 65536
    
    # IO Schedulers
    config_enable IOSCHED_BFQ
    config_enable BFQ_GROUP_IOSCHED
    config_enable MQ_IOSCHED_DEADLINE
    config_enable MQ_IOSCHED_KYBER
    
    # Device Mapper (for encryption, etc.)
    config_enable BLK_DEV_DM
    config_enable DM_CRYPT
    config_enable DM_UEVENT
    config_enable DM_VERITY
    config_enable DM_VERITY_FEC
    
    # Filesystems
    config_enable EXT4_FS
    config_enable EXT4_FS_POSIX_ACL
    config_enable EXT4_FS_SECURITY
    config_enable EXT4_ENCRYPTION
    config_enable EXT4_FS_ENCRYPTION
    config_enable EXT4_DEBUG
    
    config_enable F2FS_FS
    config_enable F2FS_FS_XATTR
    config_enable F2FS_FS_POSIX_ACL
    config_enable F2FS_FS_SECURITY
    config_enable F2FS_FS_ENCRYPTION
    config_enable F2FS_FS_COMPRESSION
    config_enable F2FS_FS_LZO
    config_enable F2FS_FS_LZ4
    config_enable F2FS_FS_ZSTD
    
    config_enable BTRFS_FS
    config_enable BTRFS_FS_POSIX_ACL
    
    # FAT/VFAT for SD cards
    config_enable FAT_FS
    config_enable VFAT_FS
    config_enable FAT_DEFAULT_UTF8
    config_set_val FAT_DEFAULT_CODEPAGE 437
    config_set_str FAT_DEFAULT_IOCHARSET "utf8"
    
    config_enable EXFAT_FS
    
    # FUSE for userspace filesystems
    config_enable FUSE_FS
    config_enable CUSE
    config_enable VIRTIO_FS
    
    # Overlay FS for container/layered storage
    config_enable OVERLAY_FS
    config_enable OVERLAY_FS_REDIRECT_DIR
    config_enable OVERLAY_FS_INDEX
    config_enable OVERLAY_FS_XINO_AUTO
    config_enable OVERLAY_FS_METACOPY
    
    # SquashFS for read-only compressed storage
    config_enable SQUASHFS
    config_enable SQUASHFS_XATTR
    config_enable SQUASHFS_ZLIB
    config_enable SQUASHFS_LZ4
    config_enable SQUASHFS_LZO
    config_enable SQUASHFS_XZ
    config_enable SQUASHFS_ZSTD
    
    # Pseudo filesystems
    config_enable PROC_FS
    config_enable PROC_KCORE
    config_enable PROC_SYSCTL
    config_enable SYSFS
    config_enable TMPFS
    config_enable TMPFS_POSIX_ACL
    config_enable TMPFS_XATTR
    config_enable CONFIGFS_FS
    
    # Security
    config_enable FS_ENCRYPTION
    config_enable FS_VERITY
    config_enable FS_VERITY_BUILTIN_SIGNATURES
    
    # Quotas
    config_enable QUOTA
    config_enable QUOTA_NETLINK_INTERFACE
    config_enable QFMT_V2
    
    # Persistent storage for logs
    config_enable PSTORE
    config_enable PSTORE_CONSOLE
    config_enable PSTORE_PMSG
    config_enable PSTORE_RAM
    
    print_msg "Storage and filesystems configured"
}

# Graphics and Display Configuration
configure_graphics() {
    print_info "Configuring Graphics and Display..."
    
    # DRM/KMS
    config_enable DRM
    config_enable DRM_MIPI_DSI
    config_enable DRM_KMS_HELPER
    config_enable DRM_KMS_FB_HELPER
    config_enable DRM_FBDEV_EMULATION
    config_set_val DRM_FBDEV_OVERALLOC 100
    config_enable DRM_GEM_CMA_HELPER
    config_enable DRM_KMS_CMA_HELPER
    config_enable DRM_GEM_SHMEM_HELPER
    config_enable DRM_PANEL
    config_enable DRM_BRIDGE
    config_enable DRM_PANEL_BRIDGE
    config_enable DRM_PANEL_ORIENTATION_QUIRKS
    
    # Framebuffer
    config_enable FB
    config_enable FB_CFB_FILLRECT
    config_enable FB_CFB_COPYAREA
    config_enable FB_CFB_IMAGEBLIT
    config_enable FB_SYS_FILLRECT
    config_enable FB_SYS_COPYAREA
    config_enable FB_SYS_IMAGEBLIT
    config_enable FB_MODE_HELPERS
    config_enable FB_TILEBLITTING
    
    # Framebuffer Console
    config_enable FRAMEBUFFER_CONSOLE
    config_enable FRAMEBUFFER_CONSOLE_DETECT_PRIMARY
    config_enable FRAMEBUFFER_CONSOLE_ROTATION
    
    # Backlight
    config_enable BACKLIGHT_LCD_SUPPORT
    config_enable LCD_CLASS_DEVICE
    config_enable BACKLIGHT_CLASS_DEVICE
    config_enable BACKLIGHT_PWM
    config_enable BACKLIGHT_GPIO
    
    # GPU/Graphics Acceleration (platform specific)
    # These would be enabled based on your hardware
    # config_enable DRM_MALI_DISPLAY
    # config_enable DRM_PANFROST
    # config_enable DRM_LIMA
    
    # Console and VT
    config_enable VT
    config_enable CONSOLE_TRANSLATIONS
    config_enable VT_CONSOLE
    config_enable VT_HW_CONSOLE_BINDING
    config_enable UNIX98_PTYS
    config_enable LEGACY_PTYS
    config_set_val LEGACY_PTY_COUNT 16
    
    # Logo
    config_enable LOGO
    config_enable LOGO_LINUX_MONO
    config_enable LOGO_LINUX_VGA16
    config_enable LOGO_LINUX_CLUT224
    
    print_msg "Graphics and display configured"
}

# Input Device Configuration
configure_input() {
    print_info "Configuring Input Devices..."
    
    config_enable INPUT
    config_enable INPUT_FF_MEMLESS
    config_enable INPUT_POLLDEV
    config_enable INPUT_SPARSEKMAP
    config_enable INPUT_MATRIXKMAP
    
    # Event interface (critical for mobile)
    config_enable INPUT_EVDEV
    
    # Touchscreen
    config_enable INPUT_TOUCHSCREEN
    config_enable TOUCHSCREEN_PROPERTIES
    config_module TOUCHSCREEN_USB_COMPOSITE
    
    # Common touchscreen drivers (enable based on hardware)
    config_module TOUCHSCREEN_GOODIX
    config_module TOUCHSCREEN_EDT_FT5X06
    config_module TOUCHSCREEN_ILITEK
    config_module TOUCHSCREEN_SILEAD
    config_module TOUCHSCREEN_EKTF2127
    config_module TOUCHSCREEN_RASPBERRYPI_FW
    config_module TOUCHSCREEN_IQS5XX
    
    # Keyboard
    config_enable INPUT_KEYBOARD
    config_enable KEYBOARD_GPIO
    config_enable KEYBOARD_GPIO_POLLED
    
    # Misc input devices
    config_enable INPUT_MISC
    config_enable INPUT_UINPUT
    config_enable INPUT_GPIO_ROTARY_ENCODER
    config_enable INPUT_GPIO_VIBRA
    config_enable INPUT_PWM_BEEPER
    config_enable INPUT_PWM_VIBRA
    
    # Sensors as input (for auto-rotation, etc.)
    config_enable INPUT_MPU3050
    config_module INPUT_BMA150
    config_module INPUT_MMA8450
    
    # Joystick support (for game controllers)
    config_enable INPUT_JOYDEV
    config_enable INPUT_JOYSTICK
    
    print_msg "Input devices configured"
}

# Network Configuration
configure_network() {
    print_info "Configuring Network Stack..."
    
    # Core networking
    config_enable NET
    config_enable INET
    config_enable IPV6
    config_enable NETLABEL
    config_enable NETWORK_PHY_TIMESTAMPING
    
    # Packet socket
    config_enable PACKET
    config_enable PACKET_DIAG
    config_enable UNIX
    config_enable UNIX_DIAG
    
    # TCP/IP
    config_enable IP_MULTICAST
    config_enable IP_ADVANCED_ROUTER
    config_enable IP_MULTIPLE_TABLES
    config_enable IP_ROUTE_MULTIPATH
    config_enable IP_PNP
    config_enable IP_PNP_DHCP
    config_enable IP_PNP_BOOTP
    config_enable NET_IPIP
    config_enable NET_IPGRE_DEMUX
    config_enable NET_IPGRE
    config_enable IP_MROUTE
    config_enable IP_MROUTE_MULTIPLE_TABLES
    config_enable SYN_COOKIES
    
    # IPv6
    config_enable IPV6_ROUTER_PREF
    config_enable IPV6_ROUTE_INFO
    config_enable IPV6_OPTIMISTIC_DAD
    config_enable IPV6_MIP6
    config_enable IPV6_VTI
    config_enable IPV6_SIT
    config_enable IPV6_TUNNEL
    config_enable IPV6_MULTIPLE_TABLES
    config_enable IPV6_MROUTE
    
    # Network filtering
    config_enable NETFILTER
    config_enable NETFILTER_ADVANCED
    config_enable NF_CONNTRACK
    config_enable NF_CONNTRACK_EVENTS
    config_enable NF_NAT
    config_enable NETFILTER_XT_NAT
    config_enable NETFILTER_XT_TARGET_MASQUERADE
    config_enable IP_NF_IPTABLES
    config_enable IP_NF_FILTER
    config_enable IP_NF_NAT
    config_enable IP_NF_TARGET_MASQUERADE
    config_enable IP6_NF_IPTABLES
    config_enable IP6_NF_FILTER
    config_enable IP6_NF_NAT
    config_enable IP6_NF_TARGET_MASQUERADE
    
    # Bridge (for containers/VMs)
    config_enable BRIDGE
    config_enable BRIDGE_NETFILTER
    config_enable VLAN_8021Q
    config_enable VLAN_8021Q_GVRP
    config_enable VLAN_8021Q_MVRP
    
    # Virtual networking
    config_enable VETH
    config_enable TUN
    config_enable TAP
    config_enable MACVLAN
    config_enable MACVTAP
    config_enable IPVLAN
    config_enable VXLAN
    
    # Wireless
    config_enable WIRELESS
    config_enable WEXT_CORE
    config_enable WEXT_PROC
    config_enable CFG80211
    config_enable CFG80211_WEXT
    config_enable MAC80211
    config_enable MAC80211_MESH
    config_enable RFKILL
    config_enable RFKILL_INPUT
    config_enable RFKILL_GPIO
    
    # Bluetooth
    config_enable BT
    config_enable BT_BREDR
    config_enable BT_RFCOMM
    config_enable BT_RFCOMM_TTY
    config_enable BT_BNEP
    config_enable BT_BNEP_MC_FILTER
    config_enable BT_BNEP_PROTO_FILTER
    config_enable BT_HIDP
    config_enable BT_HS
    config_enable BT_LE
    config_enable BT_LEDS
    config_enable BT_DEBUGFS
    
    # Common Bluetooth drivers
    config_module BT_HCIBTUSB
    config_module BT_HCIBTSDIO
    config_module BT_HCIUART
    config_module BT_HCIUART_SERDEV
    config_module BT_HCIUART_H4
    config_module BT_HCIUART_BCSP
    config_module BT_HCIUART_BCM
    config_module BT_HCIBCM203X
    config_module BT_HCIBPA10X
    config_module BT_HCIBFUSB
    config_module BT_HCIVHCI
    
    # NFC
    config_enable NFC
    config_enable NFC_DIGITAL
    config_enable NFC_NCI
    config_enable NFC_HCI
    config_enable NFC_SHDLC
    
    # Network scheduling
    config_enable NET_SCHED
    config_enable NET_SCH_FQ_CODEL
    config_enable NET_SCH_DEFAULT
    config_enable DEFAULT_FQ_CODEL
    
    # TCP congestion control
    config_enable TCP_CONG_ADVANCED
    config_enable TCP_CONG_CUBIC
    config_enable TCP_CONG_BBR
    config_enable TCP_CONG_BBR2
    config_enable DEFAULT_BBR
    
    print_msg "Network stack configured"
}

# Multimedia Configuration
configure_multimedia() {
    print_info "Configuring Multimedia Support..."
    
    # Media subsystem
    config_enable MEDIA_SUPPORT
    config_enable MEDIA_CAMERA_SUPPORT
    config_enable MEDIA_ANALOG_TV_SUPPORT
    config_enable MEDIA_DIGITAL_TV_SUPPORT
    config_enable MEDIA_RADIO_SUPPORT
    config_enable MEDIA_CONTROLLER
    config_enable VIDEO_DEV
    config_enable VIDEO_V4L2
    config_enable VIDEO_V4L2_SUBDEV_API
    config_enable V4L2_MEM2MEM_DEV
    
    # Video buffer
    config_enable VIDEOBUF2_CORE
    config_enable VIDEOBUF2_V4L2
    config_enable VIDEOBUF2_MEMOPS
    config_enable VIDEOBUF2_DMA_CONTIG
    config_enable VIDEOBUF2_VMALLOC
    config_enable VIDEOBUF2_DMA_SG
    
    # Sound subsystem
    config_enable SOUND
    config_enable SND
    config_enable SND_TIMER
    config_enable SND_PCM
    config_enable SND_DMAENGINE_PCM
    config_enable SND_HWDEP
    config_enable SND_RAWMIDI
    config_enable SND_COMPRESS_OFFLOAD
    config_enable SND_JACK
    config_enable SND_JACK_INPUT_DEV
    
    # ALSA
    config_enable SND_MIXER_OSS
    config_enable SND_PCM_OSS
    config_enable SND_PCM_OSS_PLUGINS
    config_enable SND_PCM_TIMER
    config_enable SND_HRTIMER
    config_enable SND_DYNAMIC_MINORS
    config_enable SND_SUPPORT_OLD_API
    config_enable SND_PROC_FS
    config_enable SND_VERBOSE_PROCFS
    
    # USB Audio
    config_module SND_USB_AUDIO
    config_module SND_USB_UA101
    config_module SND_USB_CAIAQ
    config_module SND_USB_6FIRE
    config_module SND_USB_HIFACE
    
    # SoC Audio
    config_enable SND_SOC
    config_enable SND_SOC_COMPRESS
    config_enable SND_SOC_TOPOLOGY
    config_enable SND_SOC_GENERIC_DMAENGINE_PCM
    
    # Common codecs (enable based on hardware)
    config_module SND_SOC_ES8316
    config_module SND_SOC_RT5640
    config_module SND_SOC_RT5651
    config_module SND_SOC_SPDIF
    config_module SND_SIMPLE_CARD
    config_module SND_AUDIO_GRAPH_CARD
    
    print_msg "Multimedia configured"
}

# USB Configuration
configure_usb() {
    print_info "Configuring USB Support..."
    
    # USB Host
    config_enable USB_SUPPORT
    config_enable USB
    config_enable USB_ANNOUNCE_NEW_DEVICES
    config_enable USB_DEFAULT_PERSIST
    config_enable USB_MON
    
    # USB Controllers
    config_enable USB_XHCI_HCD
    config_enable USB_XHCI_PLATFORM
    config_enable USB_EHCI_HCD
    config_enable USB_EHCI_HCD_PLATFORM
    config_enable USB_OHCI_HCD
    config_enable USB_OHCI_HCD_PLATFORM
    config_enable USB_DWC3
    config_enable USB_DWC3_DUAL_ROLE
    config_enable USB_DWC2
    config_enable USB_DWC2_DUAL_ROLE
    config_enable USB_CHIPIDEA
    config_enable USB_CHIPIDEA_UDC
    config_enable USB_CHIPIDEA_HOST
    
    # USB Gadget (for device mode)
    config_enable USB_GADGET
    config_enable USB_GADGET_VBUS_DRAW
    config_enable USB_GADGET_STORAGE_NUM_BUFFERS
    config_enable USB_LIBCOMPOSITE
    config_enable USB_F_ACM
    config_enable USB_F_SS_LB
    config_enable USB_U_SERIAL
    config_enable USB_U_ETHER
    config_enable USB_U_AUDIO
    config_enable USB_F_SERIAL
    config_enable USB_F_OBEX
    config_enable USB_F_NCM
    config_enable USB_F_ECM
    config_enable USB_F_RNDIS
    config_enable USB_F_MASS_STORAGE
    config_enable USB_F_FS
    config_enable USB_F_UAC1
    config_enable USB_F_UAC2
    config_enable USB_F_UVC
    config_enable USB_F_MIDI
    config_enable USB_F_HID
    config_enable USB_F_PRINTER
    
    # USB Gadget configs
    config_enable USB_CONFIGFS
    config_enable USB_CONFIGFS_SERIAL
    config_enable USB_CONFIGFS_ACM
    config_enable USB_CONFIGFS_NCM
    config_enable USB_CONFIGFS_ECM
    config_enable USB_CONFIGFS_RNDIS
    config_enable USB_CONFIGFS_MASS_STORAGE
    config_enable USB_CONFIGFS_F_FS
    config_enable USB_CONFIGFS_F_UAC1
    config_enable USB_CONFIGFS_F_UAC2
    config_enable USB_CONFIGFS_F_MIDI
    config_enable USB_CONFIGFS_F_HID
    
    # USB OTG
    config_enable USB_OTG
    config_enable USB_OTG_FSM
    
    # USB Storage
    config_enable USB_STORAGE
    config_enable USB_UAS
    
    # USB Network adapters
    config_module USB_USBNET
    config_module USB_NET_AX8817X
    config_module USB_NET_AX88179_178A
    config_module USB_NET_CDCETHER
    config_module USB_NET_CDC_NCM
    config_module USB_NET_RNDIS_HOST
    
    # USB Serial
    config_module USB_SERIAL
    config_module USB_SERIAL_GENERIC
    config_module USB_SERIAL_FTDI_SIO
    config_module USB_SERIAL_PL2303
    config_module USB_SERIAL_CP210X
    config_module USB_SERIAL_CH341
    
    # USB Type-C
    config_enable TYPEC
    config_enable TYPEC_TCPM
    config_enable TYPEC_TCPCI
    config_enable USB_ROLE_SWITCH
    
    print_msg "USB configured"
}

# Security Configuration
configure_security() {
    print_info "Configuring Security Features..."
    
    # Core security
    config_enable SECURITY
    config_enable SECURITY_NETWORK
    config_enable SECURITY_PATH
    config_enable SECURITY_DMESG_RESTRICT
    config_enable SECURITYFS
    
    # Keys/Keyrings
    config_enable KEYS
    config_enable KEYS_REQUEST_CACHE
    config_enable PERSISTENT_KEYRINGS
    config_enable ENCRYPTED_KEYS
    config_enable KEY_DH_OPERATIONS
    
    # Hardening
    config_enable HARDENED_USERCOPY
    config_enable FORTIFY_SOURCE
    config_enable INIT_STACK_ALL_ZERO
    config_enable INIT_ON_ALLOC_DEFAULT_ON
    config_enable INIT_ON_FREE_DEFAULT_ON
    
    # Stack protection
    config_enable STACKPROTECTOR
    config_enable STACKPROTECTOR_STRONG
    config_enable STACK_VALIDATION
    
    # SELinux (optional, but recommended)
    config_enable SECURITY_SELINUX
    config_enable SECURITY_SELINUX_BOOTPARAM
    config_enable SECURITY_SELINUX_DEVELOP
    config_enable SECURITY_SELINUX_AVC_STATS
    config_enable DEFAULT_SECURITY_SELINUX
    
    # AppArmor (alternative to SELinux)
    config_enable SECURITY_APPARMOR
    config_enable SECURITY_APPARMOR_BOOTPARAM
    
    # Integrity subsystem
    config_enable INTEGRITY
    config_enable INTEGRITY_SIGNATURE
    config_enable IMA
    config_enable IMA_APPRAISE
    config_enable EVM
    
    # Yama security module
    config_enable SECURITY_YAMA
    
    # LoadPin security module
    config_enable SECURITY_LOADPIN
    config_enable SECURITY_LOADPIN_ENFORCE
    
    # Lockdown
    config_enable SECURITY_LOCKDOWN_LSM
    config_enable SECURITY_LOCKDOWN_LSM_EARLY
    
    # Crypto API
    config_enable CRYPTO
    config_enable CRYPTO_MANAGER
    config_enable CRYPTO_USER
    config_enable CRYPTO_CRYPTD
    config_enable CRYPTO_AUTHENC
    config_enable CRYPTO_CCM
    config_enable CRYPTO_GCM
    config_enable CRYPTO_SEQIV
    config_enable CRYPTO_CBC
    config_enable CRYPTO_CTR
    config_enable CRYPTO_ECB
    config_enable CRYPTO_XTS
    config_enable CRYPTO_HMAC
    config_enable CRYPTO_XCBC
    config_enable CRYPTO_VMAC
    config_enable CRYPTO_CRC32C
    config_enable CRYPTO_MD4
    config_enable CRYPTO_MD5
    config_enable CRYPTO_SHA1
    config_enable CRYPTO_SHA256
    config_enable CRYPTO_SHA512
    config_enable CRYPTO_SHA3
    config_enable CRYPTO_AES
    config_enable CRYPTO_DES
    config_enable CRYPTO_TWOFISH
    config_enable CRYPTO_SERPENT
    config_enable CRYPTO_CAMELLIA
    config_enable CRYPTO_CAST5
    config_enable CRYPTO_CAST6
    config_enable CRYPTO_DEFLATE
    config_enable CRYPTO_LZO
    config_enable CRYPTO_842
    config_enable CRYPTO_LZ4
    config_enable CRYPTO_LZ4HC
    config_enable CRYPTO_ZSTD
    config_enable CRYPTO_ANSI_CPRNG
    config_enable CRYPTO_DRBG_HMAC
    config_enable CRYPTO_DRBG_HASH
    config_enable CRYPTO_DRBG_CTR
    config_enable CRYPTO_USER_API_HASH
    config_enable CRYPTO_USER_API_SKCIPHER
    config_enable CRYPTO_USER_API_RNG
    config_enable CRYPTO_USER_API_AEAD
    
    # Hardware crypto support (platform specific)
    config_enable CRYPTO_HW
    config_enable CRYPTO_DEV_ALLWINNER_SUN4I_SS
    config_enable CRYPTO_DEV_ALLWINNER_SUN8I_CE
    config_enable CRYPTO_DEV_ALLWINNER_SUN8I_SS
    config_enable CRYPTO_DEV_ROCKCHIP
    config_enable CRYPTO_DEV_VIRTIO
    
    print_msg "Security configured"
}

# Sensor/IIO Configuration
configure_sensors() {
    print_info "Configuring Sensors (IIO)..."
    
    config_enable IIO
    config_enable IIO_BUFFER
    config_enable IIO_BUFFER_CB
    config_enable IIO_KFIFO_BUF
    config_enable IIO_TRIGGERED_BUFFER
    config_enable IIO_TRIGGER
    config_enable IIO_CONSUMERS_PER_TRIGGER
    
    # Accelerometers
    config_module BMA180
    config_module BMA220
    config_module BMA400
    config_module BMC150_ACCEL
    config_module MMA8452
    config_module MMA9551
    config_module MMA9553
    config_module STK8312
    config_module STK8BA50
    
    # Gyroscopes
    config_module ADIS16080
    config_module ADIS16130
    config_module ADIS16136
    config_module ADIS16260
    config_module ADXRS450
    config_module BMG160
    config_module MPU3050
    
    # Magnetometers
    config_module AK8974
    config_module AK8975
    config_module AK09911
    config_module BMC150_MAGN
    config_module MAG3110
    config_module HMC5843
    config_module SENSORS_HMC5843
    
    # Light sensors
    config_module ADJD_S311
    config_module AL3320A
    config_module APDS9300
    config_module APDS9960
    config_module BH1750
    config_module BH1780
    config_module CM32181
    config_module CM3232
    config_module CM3323
    config_module CM3605
    config_module CM36651
    config_module GP2AP020A00F
    config_module ISL29018
    config_module ISL29125
    config_module JSA1212
    config_module LTR501
    config_module MAX44000
    config_module OPT3001
    config_module PA12203001
    config_module STK3310
    config_module TCS3414
    config_module TCS3472
    config_module SENSORS_TSL2563
    config_module TSL2583
    config_module TSL2772
    config_module TSL4531
    config_module US5182D
    config_module VCNL4000
    config_module VCNL4035
    config_module VEML6070
    config_module VL6180
    
    # Proximity sensors
    config_module AS3935
    config_module ISL29501
    config_module LIDAR_LITE_V2
    config_module MB1232
    config_module RFD77402
    config_module SRF04
    config_module SX9310
    config_module SX9500
    config_module SRF08
    config_module VL53L0X
    
    # Pressure sensors
    config_module ABP060MG
    config_module BMP280
    config_module HP03
    config_module MPL115
    config_module MPL3115
    config_module MS5611
    config_module MS5637
    config_module IIO_ST_PRESS
    config_module T5403
    config_module HP206C
    config_module ZPA2326
    
    # Temperature sensors
    config_module LM3533_ALS
    config_module MLX90614
    config_module MLX90632
    config_module TMP006
    config_module TMP007
    config_module TSYS01
    config_module TSYS02D
    
    # Humidity sensors
    config_module AM2315
    config_module DHT11
    config_module HDC100X
    config_module HDC2010
    config_module HTS221
    config_module HTU21
    config_module SI7005
    config_module SI7020
    
    # IMU (Inertial Measurement Units)
    config_module ADIS16400
    config_module ADIS16460
    config_module ADIS16475
    config_module ADIS16480
    config_module BMI160
    config_module FXOS8700
    config_module KMX61
    config_module INV_MPU6050
    config_module INV_ICM42600
    config_module IIO_ST_LSM6DSX
    config_module IIO_ST_LSM9DS0
    
    print_msg "Sensors configured"
}

# Hardware Bus Configuration
configure_hardware_buses() {
    print_info "Configuring Hardware Buses..."
    
    # I2C
    config_enable I2C
    config_enable I2C_CHARDEV
    config_enable I2C_MUX
    config_enable I2C_HELPER_AUTO
    config_enable I2C_SMBUS
    config_enable I2C_GPIO
    config_enable I2C_GPIO_FAULT_INJECTOR
    
    # SPI
    config_enable SPI
    config_enable SPI_MASTER
    config_enable SPI_MEM
    config_enable SPI_GPIO
    config_enable SPI_SPIDEV
    
    # GPIO
    config_enable GPIOLIB
    config_enable GPIOLIB_FASTPATH_LIMIT
    config_enable GPIO_SYSFS
    config_enable GPIO_CDEV
    config_enable GPIO_CDEV_V1
    
    # PWM
    config_enable PWM
    config_enable PWM_SYSFS
    
    # Pin Control
    config_enable PINCTRL
    config_enable PINMUX
    config_enable PINCONF
    config_enable GENERIC_PINCONF
    config_enable DEBUG_PINCTRL
    
    # Regulators
    config_enable REGULATOR
    config_enable REGULATOR_FIXED_VOLTAGE
    config_enable REGULATOR_VIRTUAL_CONSUMER
    config_enable REGULATOR_USERSPACE_CONSUMER
    config_enable REGULATOR_GPIO
    config_enable REGULATOR_PWM
    
    # Clock framework
    config_enable COMMON_CLK
    config_enable COMMON_CLK_DEBUG
    
    # Reset controller
    config_enable RESET_CONTROLLER
    
    # PHY Subsystem
    config_enable GENERIC_PHY
    config_enable PHY_SUN4I_USB
    config_enable PHY_SUN6I_MIPI_DPHY
    
    # Mailbox
    config_enable MAILBOX
    
    # IOMMU
    config_enable IOMMU_SUPPORT
    config_enable IOMMU_IO_PGTABLE
    config_enable IOMMU_IO_PGTABLE_LPAE
    config_enable IOMMU_IO_PGTABLE_ARMV7S
    config_enable OF_IOMMU
    config_enable IOMMU_DMA
    
    print_msg "Hardware buses configured"
}

# Device Drivers - Platform Specific
configure_platform_drivers() {
    print_info "Configuring Platform-Specific Drivers..."
    
    # MMC/SD/SDIO
    config_enable MMC
    config_enable MMC_BLOCK
    config_set_val MMC_BLOCK_MINORS 32
    config_enable SDIO_UART
    config_enable MMC_TEST
    
    # Common MMC drivers
    config_enable MMC_SDHCI
    config_enable MMC_SDHCI_PLTFM
    config_enable MMC_SDHCI_OF_ARASAN
    config_enable MMC_SDHCI_OF_AT91
    config_enable MMC_SDHCI_OF_DWCMSHC
    config_enable MMC_SPI
    config_enable MMC_DW
    config_enable MMC_DW_PLTFM
    config_enable MMC_SUNXI
    config_enable MMC_BCM2835
    
    # MTD for raw flash
    config_enable MTD
    config_enable MTD_CMDLINE_PARTS
    config_enable MTD_BLOCK
    config_enable MTD_RAW_NAND
    config_enable MTD_SPI_NOR
    config_enable MTD_UBI
    config_enable UBIFS_FS
    
    # LED subsystem
    config_enable NEW_LEDS
    config_enable LEDS_CLASS
    config_enable LEDS_CLASS_FLASH
    config_enable LEDS_CLASS_MULTICOLOR
    config_enable LEDS_GPIO
    config_enable LEDS_PWM
    config_enable LEDS_REGULATOR
    config_enable LEDS_TRIGGERS
    config_enable LEDS_TRIGGER_TIMER
    config_enable LEDS_TRIGGER_ONESHOT
    config_enable LEDS_TRIGGER_HEARTBEAT
    config_enable LEDS_TRIGGER_BACKLIGHT
    config_enable LEDS_TRIGGER_CPU
    config_enable LEDS_TRIGGER_ACTIVITY
    config_enable LEDS_TRIGGER_GPIO
    config_enable LEDS_TRIGGER_DEFAULT_ON
    config_enable LEDS_TRIGGER_TRANSIENT
    config_enable LEDS_TRIGGER_CAMERA
    config_enable LEDS_TRIGGER_PANIC
    config_enable LEDS_TRIGGER_NETDEV
    config_enable LEDS_TRIGGER_PATTERN
    config_enable LEDS_TRIGGER_AUDIO
    
    # RTC
    config_enable RTC_CLASS
    config_enable RTC_HCTOSYS
    config_set_str RTC_HCTOSYS_DEVICE "rtc0"
    config_enable RTC_SYSTOHC
    config_enable RTC_INTF_SYSFS
    config_enable RTC_INTF_PROC
    config_enable RTC_INTF_DEV
    
    # Watchdog
    config_enable WATCHDOG
    config_enable WATCHDOG_CORE
    config_enable WATCHDOG_NOWAYOUT
    config_enable WATCHDOG_HANDLE_BOOT_ENABLED
    config_enable WATCHDOG_SYSFS
    config_enable SOFT_WATCHDOG
    config_enable GPIO_WATCHDOG
    
    # Hardware monitoring
    config_enable HWMON
    config_enable SENSORS_GPIO_FAN
    config_enable SENSORS_PWM_FAN
    config_enable SENSORS_IIO_HWMON
    config_enable THERMAL_HWMON
    
    # Battery/Power
    config_enable POWER_SUPPLY
    config_enable POWER_SUPPLY_HWMON
    config_enable CHARGER_MANAGER
    config_enable BATTERY_MAX17040
    config_enable BATTERY_MAX17042
    config_enable BATTERY_SBS
    config_enable CHARGER_GPIO
    config_enable CHARGER_BQ2415X
    config_enable CHARGER_BQ24190
    config_enable CHARGER_BQ24257
    config_enable CHARGER_BQ24735
    config_enable CHARGER_BQ25890
    config_enable BATTERY_GAUGE_LTC2941
    config_enable BATTERY_RT5033
    config_enable CHARGER_RT5033
    
    # Extcon (External Connectors)
    config_enable EXTCON
    config_enable EXTCON_ADC_JACK
    config_enable EXTCON_GPIO
    config_enable EXTCON_MAX14577
    config_enable EXTCON_MAX77693
    config_enable EXTCON_MAX77843
    config_enable EXTCON_MAX8997
    config_enable EXTCON_PALMAS
    config_enable EXTCON_RT8973A
    config_enable EXTCON_SM5502
    config_enable EXTCON_USB_GPIO
    config_enable EXTCON_USBC_TUSB320
    
    # NVMEM
    config_enable NVMEM
    config_enable NVMEM_SYSFS
    
    # DMA
    config_enable DMADEVICES
    config_enable DMA_ENGINE
    config_enable DMA_OF
    
    # Remote processors
    config_enable REMOTEPROC
    config_enable RPMSG
    
    # Performance events
    config_enable PERF_EVENTS
    config_enable HW_PERF_EVENTS
    
    print_msg "Platform-specific drivers configured"
}

# Development and Debug Options
configure_debug() {
    print_info "Configuring Debug Options..."
    
    local response
    read -p "Enable debug features? (y/n) [n]: " response
    
    if [[ "$response" =~ ^[Yy]$ ]]; then
        config_enable DEBUG_KERNEL
        config_enable DEBUG_INFO
        config_enable DEBUG_INFO_DWARF_TOOLCHAIN_DEFAULT
        config_enable FRAME_POINTER
        config_enable MAGIC_SYSRQ
        config_enable DEBUG_FS
        config_enable HEADERS_INSTALL
        config_enable KGDB
        config_enable KGDB_SERIAL_CONSOLE
        config_enable DEBUG_MEMORY_INIT
        config_enable PANIC_ON_OOPS
        config_set_val PANIC_TIMEOUT 0
        config_enable LOCKUP_DETECTOR
        config_enable SOFTLOCKUP_DETECTOR
        config_enable HARDLOCKUP_DETECTOR
        config_enable DETECT_HUNG_TASK
        config_enable WQ_WATCHDOG
        config_enable FTRACE
        config_enable FUNCTION_TRACER
        config_enable FUNCTION_GRAPH_TRACER
        config_enable DYNAMIC_FTRACE
        config_enable FTRACE_SYSCALLS
        config_enable TRACER_SNAPSHOT
        config_enable KPROBES
        config_enable KPROBE_EVENTS
        config_enable UPROBE_EVENTS
        config_enable PROFILING
        config_enable PERF_EVENTS
        
        print_msg "Debug features enabled"
    else
        print_msg "Debug features skipped (production mode)"
    fi
}

# Validation
validate_config() {
    print_info "Validating configuration..."
    
    local errors=0
    local warnings=0
    
    # Check critical options
    local critical_options=(
        "CONFIG_MODULES"
        "CONFIG_BLOCK"
        "CONFIG_NET"
        "CONFIG_INET"
        "CONFIG_PM"
        "CONFIG_PM_SLEEP"
        "CONFIG_SUSPEND"
        "CONFIG_MMC"
        "CONFIG_INPUT"
        "CONFIG_INPUT_EVDEV"
        "CONFIG_VT"
        "CONFIG_UNIX"
        "CONFIG_TMPFS"
        "CONFIG_SHMEM"
    )
    
    for option in "${critical_options[@]}"; do
        if ! grep -q "^${option}=y" "$CONFIG_FILE" 2>/dev/null; then
            print_error "Critical option not enabled: $option"
            ((errors++))
        fi
    done
    
    # Check recommended options
    local recommended_options=(
        "CONFIG_CRYPTO"
        "CONFIG_SECURITY"
        "CONFIG_AUDIT"
        "CONFIG_CGROUPS"
        "CONFIG_NAMESPACES"
        "CONFIG_IPC_NS"
        "CONFIG_NET_NS"
        "CONFIG_PID_NS"
        "CONFIG_USER_NS"
        "CONFIG_DEVTMPFS"
        "CONFIG_DEVTMPFS_MOUNT"
    )
    
    for option in "${recommended_options[@]}"; do
        if ! grep -q "^${option}=y" "$CONFIG_FILE" 2>/dev/null; then
            print_warning "Recommended option not enabled: $option"
            ((warnings++))
        fi
    done
    
    if [ $errors -gt 0 ]; then
        print_error "Validation failed with $errors critical errors"
        return 1
    fi
    
    if [ $warnings -gt 0 ]; then
        print_warning "Validation completed with $warnings warnings"
    else
        print_msg "Configuration validation passed!"
    fi
    
    return 0
}

# Main execution
main() {
    print_info "Custom Mobile OS Kernel Configuration"
    print_info "======================================="
    print_info "Kernel Directory: $KERNEL_DIR"
    echo
    
    # Check if kernel directory exists
    if [ ! -d "$KERNEL_DIR" ]; then
        print_error "Kernel directory not found: $KERNEL_DIR"
        print_info "Please set KERNEL_DIR environment variable"
        exit 1
    fi
    
    # Check for kernel source files
    if [ ! -f "$KERNEL_DIR/Makefile" ] || [ ! -f "$KERNEL_DIR/Kconfig" ]; then
        print_error "Invalid kernel source directory"
        exit 1
    fi
    
    # Initialize
    init_config
    
    # Configure all subsystems
    print_info "Starting configuration..."
    echo
    
    configure_core_system
    configure_power_management
    configure_memory_management
    configure_storage
    configure_graphics
    configure_input
    configure_network
    configure_multimedia
    configure_usb
    configure_security
    configure_sensors
    configure_hardware_buses
    configure_platform_drivers
    
    # Optional debug configuration
    configure_debug
    
    # Resolve dependencies
    print_info "Resolving configuration dependencies..."
    cd "$KERNEL_DIR"
    make olddefconfig
    
    # Validate
    echo
    validate_config
    
    # Summary
    echo
    print_info "Configuration Summary"
    print_info "===================="
    print_msg "Configuration file: $CONFIG_FILE"
    print_msg "Backup directory: $BACKUP_DIR"
    echo
    print_info "Next steps:"
    echo "  1. Review configuration:  make menuconfig"
    echo "  2. Build kernel:          make -j$(nproc)"
    echo "  3. Build modules:         make modules"
    echo "  4. Install modules:       sudo make modules_install"
    echo "  5. Install kernel:        sudo make install"
    echo
    print_info "For device tree compilation (if needed):"
    echo "  make dtbs"
    echo
    print_info "Remember to:"
    echo "  - Configure platform-specific drivers for your hardware"
    echo "  - Enable appropriate WiFi/Bluetooth drivers"
    echo "  - Configure your bootloader (U-Boot, GRUB, etc.)"
    echo "  - Create an initramfs if needed"
}

# Run main function
main "$@"