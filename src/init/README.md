# Aether OS Init System

The init system manages system boot, service lifecycle, and shutdown for Aether OS.

## Architecture

```
┌─────────────────────────────────────────┐
│            Bootloader (U-Boot)          │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│         Kernel Initialization           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│      aether-startup (Early Boot)        │
│   - Mount filesystems                   │
│   - Load modules                        │
│   - Initialize devices                  │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│        systemd Init System              │
│   - aetheros-system.target              │
│   - aetheros-graphical.target           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│       System Services (systemd)         │
│   - aether-power.service                │
│   - aether-network.service              │
│   - aether-audio.service                │
│   - aether-display.service              │
│   - aether-compositor.service           │
└───────────────┬─────────────────────────┘
                │
                ▼
┌─────────────────────────────────────────┐
│     Health Monitor (Watchdog)           │
└─────────────────────────────────────────┘
```

## Components

### Systemd Service Units (`systemd/`)

Production-ready systemd service files for all Aether OS services.

**Available Services:**
- `aether-power.service` - Power management
- `aether-network.service` - Network connectivity
- `aether-audio.service` - Audio system
- `aether-display.service` - Display server
- `aether-compositor.service` - Wayland compositor
- `aether-service-manager.service` - Service orchestration
- `aether-health-monitor.service` - Service health monitoring

**System Targets:**
- `aetheros-system.target` - Core system services
- `aetheros-graphical.target` - Graphical environment

### Boot Scripts (`scripts/`)

Scripts for system initialization and management.

**aether-startup**
- Early boot initialization
- Filesystem mounting and checking
- Kernel module loading
- Device initialization
- Network setup
- Graphics initialization

**aether-shutdown**
- Graceful service shutdown
- Process termination
- Filesystem unmounting
- Power off/reboot

**aether-service-manager**
- Centralized service management
- Start/stop/restart all services
- Service status monitoring
- Health checking
- Enable/disable services

**aether-health-monitor**
- Continuous service monitoring
- Automatic service recovery
- Resource usage monitoring
- Health report generation

### Recovery Mode (`recovery/`)

System recovery and maintenance tools.

**recovery-mode.sh**
- Safe boot environment
- Service restart
- Filesystem repair
- Backup restore
- Factory reset
- System logs viewing

## Installation

### Install systemd Service Files

```bash
# Copy service files
sudo cp src/init/systemd/*.service /etc/systemd/system/
sudo cp src/init/systemd/*.target /etc/systemd/system/

# Copy scripts
sudo cp src/init/scripts/* /usr/bin/
sudo chmod +x /usr/bin/aether-*

# Reload systemd
sudo systemctl daemon-reload
```

### Enable Services

```bash
# Enable all Aether OS services
aether-service-manager enable

# Or enable individually
sudo systemctl enable aether-power.service
sudo systemctl enable aether-network.service
sudo systemctl enable aether-audio.service
sudo systemctl enable aether-display.service
sudo systemctl enable aether-compositor.service
sudo systemctl enable aether-health-monitor.service
```

### Set Default Target

```bash
# Set graphical target as default
sudo systemctl set-default aetheros-graphical.target
```

## Usage

### Service Management

```bash
# Start all services
aether-service-manager start

# Stop all services
aether-service-manager stop

# Restart all services
aether-service-manager restart

# Check service status
aether-service-manager status

# Health check
aether-service-manager health
```

### Individual Service Control

```bash
# Start a service
sudo systemctl start aether-power.service

# Stop a service
sudo systemctl stop aether-power.service

# Restart a service
sudo systemctl restart aether-power.service

# Check service status
sudo systemctl status aether-power.service

# View service logs
sudo journalctl -u aether-power.service -f
```

### Health Monitoring

The health monitor runs automatically and:
- Checks service status every 30 seconds
- Automatically restarts failed services
- Limits restarts to 3 per 5 minutes
- Generates health reports in `/run/aetheros/health/`

View health report:
```bash
cat /run/aetheros/health/health_report.txt
```

### Recovery Mode

Boot into recovery mode:

1. **From bootloader**: Select "Aether OS (Recovery Mode)"
2. **From running system**: Add `recovery` to kernel command line
3. **From shell**: Run `recovery-mode.sh`

Recovery mode provides:
- Service restart
- Filesystem repair
- Backup restore
- Factory reset
- System logs
- Emergency shell

## Boot Process

### 1. Bootloader Stage

- U-Boot loads kernel and initramfs
- Kernel boots with command line parameters
- Initial ramdisk is mounted

### 2. Early Boot Stage (`aether-startup`)

```bash
# Runs automatically at boot
# Located in: /usr/bin/aether-startup
```

Actions:
- Mounts essential filesystems (`/proc`, `/sys`, `/dev`, `/tmp`, `/run`)
- Creates device nodes
- Loads kernel modules
- Checks and mounts data partition
- Initializes network (loopback)
- Sets up DRM/graphics
- Creates runtime directories
- Loads system configuration

### 3. Systemd Stage

systemd takes over and:
- Starts `aetheros-system.target`
  - Starts power management
  - Starts network service
  - Starts audio service
- Starts `aetheros-graphical.target`
  - Starts display service
  - Starts compositor
- Starts health monitor
- Reaches `default.target`

### 4. Graphical Environment

- Compositor is running
- Display server is ready
- Applications can be launched

## Shutdown Process

### 1. Initiate Shutdown

```bash
# Power off
sudo systemctl poweroff
# or
sudo aether-shutdown poweroff

# Reboot
sudo systemctl reboot
# or
sudo aether-shutdown reboot
```

### 2. Shutdown Sequence (`aether-shutdown`)

1. Save system state
2. Stop user services (apps, compositor)
3. Stop system services (in reverse order)
4. Terminate remaining processes
5. Sync filesystems
6. Unmount partitions
7. Power off or reboot

## Service Dependencies

Services start in this order:

1. **aether-power** (no dependencies)
2. **aether-network** (after power)
3. **aether-audio** (after power)
4. **aether-display** (after power, network)
5. **aether-compositor** (requires display)

Health monitor starts after all system services.

## Configuration

### Service Configuration

Edit service configuration:
```bash
sudo systemctl edit aether-power.service
```

Override service settings:
```bash
# Create override
sudo systemctl edit --full aether-power.service

# Reload after changes
sudo systemctl daemon-reload
sudo systemctl restart aether-power.service
```

### Boot Configuration

Edit boot configuration:
```bash
# Edit kernel command line
sudo nano /boot/aetheros.bootconfig

# Update bootloader
sudo update-bootloader
```

Boot modes:
- Normal: `(default)`
- Recovery: `recovery`
- Safe mode: `safe`

## Troubleshooting

### Service Won't Start

```bash
# Check service status
sudo systemctl status aether-power.service

# View detailed logs
sudo journalctl -u aether-power.service -n 50

# Check dependencies
systemctl list-dependencies aether-power.service

# Test service manually
/usr/bin/aether-power-service
```

### Service Keeps Restarting

```bash
# Check health monitor logs
tail -f /var/log/aether-health-monitor.log

# Check restart count
cat /run/aetheros/health/aether-power.restarts

# Temporarily disable health monitor
sudo systemctl stop aether-health-monitor.service
```

### Boot Failure

1. Boot into recovery mode
2. Check logs:
   ```bash
   less /var/log/aether-startup.log
   dmesg | less
   ```
3. Repair filesystem:
   ```bash
   fsck -y /dev/mmcblk0p3
   ```
4. Reset services:
   ```bash
   systemctl reset-failed
   ```

### System Hangs at Boot

1. Boot with `recovery` parameter
2. Check which service is hanging:
   ```bash
   systemctl list-jobs
   ```
3. Disable problematic service:
   ```bash
   systemctl mask aether-problem.service
   ```
4. Reboot normally

## Development

### Adding New Services

1. Create systemd service file:
   ```bash
   sudo nano /etc/systemd/system/my-service.service
   ```

2. Add to service manager:
   Edit `/usr/bin/aether-service-manager`:
   ```bash
   SERVICES=(
       ...
       "my-service"
   )
   ```

3. Enable and start:
   ```bash
   sudo systemctl daemon-reload
   sudo systemctl enable my-service.service
   sudo systemctl start my-service.service
   ```

### Testing Changes

```bash
# Test service file syntax
systemd-analyze verify my-service.service

# Test boot sequence
systemd-analyze plot > boot.svg

# Check boot time
systemd-analyze blame

# Check critical chain
systemd-analyze critical-chain
```

## Performance

### Boot Time Optimization

```bash
# Analyze boot time
systemd-analyze

# Find slow services
systemd-analyze blame

# Optimize critical path
systemd-analyze critical-chain
```

Tips:
- Enable parallel service startup
- Use `Type=notify` for faster startup detection
- Minimize service dependencies
- Use socket activation where possible

### Resource Limits

Services have resource limits:
- **Memory**: 128M-512M per service
- **CPU**: 10%-80% quota
- **I/O**: Appropriate scheduling class

Adjust in service files:
```ini
[Service]
MemoryMax=256M
CPUQuota=30%
IOSchedulingClass=realtime
```

## Security

### Service Isolation

Services run with:
- `NoNewPrivileges=true` - Prevents privilege escalation
- `PrivateTmp=true` - Isolated /tmp
- `ProtectSystem=strict` - Read-only system
- `ProtectHome=true` - No home directory access

### Capabilities

Network service needs specific capabilities:
```ini
[Service]
CapabilityBoundingSet=CAP_NET_ADMIN CAP_NET_RAW
AmbientCapabilities=CAP_NET_ADMIN CAP_NET_RAW
```

## Best Practices

1. **Always use systemd** for service management
2. **Monitor health** - Let health monitor handle failures
3. **Check logs** - Use `journalctl` for debugging
4. **Test changes** - Verify services before enabling
5. **Use recovery mode** - For system repairs
6. **Keep backups** - Before major changes

## References

- systemd documentation: https://www.freedesktop.org/wiki/Software/systemd/
- systemd service files: `man systemd.service`
- systemd targets: `man systemd.target`
- Journal logging: `man journalctl`
