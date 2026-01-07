# Samsung Galaxy A14 5G (SM-A146B/M) - KernelSU Custom Kernel

This repository contains a custom kernel for Samsung Galaxy A14 5G (SM-A146B/M) with KernelSU support and Android 14 compatibility.

## Device specifications

Basic      | Spec Sheet
----------:|:-------------------------
SoC        | Exynos 1330 (s5e8535)
CPU        | Octa-core (2x2.4GHz Cortex-A78 6x2GHz Cortex-A55)
GPU        | Mali-G68 MP2
Technology | GSM, HSPA, LTE, 5G
Memory     | 4/6/8 GB RAM
Storage    | 64/128 GB
Battery    | Non-removable Li-ion 5000 mAh battery
Display    | 1080 x 2408 pixels, 20.1:9 ratio, 6.6 inches, PLS LCD 90Hz
Camera     | 50 MP(wide) + 2 MP(macro) + 2 MP(macro) triple camera

## 📋 Table of Contents

- [Building the Kernel](#building-the-kernel)
- [Creating AnyKernel3 Flashable ZIP](#creating-anykernel3-flashable-zip)
- [Installation Requirements](#installation-requirements)
- [Device Compatibility (A146B vs A146M)](#device-compatibility-a146b-vs-a146m)
- [Kernel Tuning Options](#kernel-tuning-options)
- [Troubleshooting](#troubleshooting)

---

## 🔨 Building the Kernel

### Prerequisites

- Linux-based system (Ubuntu/Debian recommended)
- Required toolchains (clang, build-tools) - see `build_kernel.sh` for paths
- At least 16GB RAM and 50GB free disk space
- Basic knowledge of kernel compilation

### Build Steps

1. **Clone the repository**
   ```bash
   git clone https://github.com/narutojgdr-sudo/SM-A146B-KSU-BUILD-ANDROID-14-UPDATED.git
   cd SM-A146B-KSU-BUILD-ANDROID-14-UPDATED
   ```

2. **Initialize submodules (if any)**
   ```bash
   git submodule update --init --recursive
   ```

3. **Set up toolchains**
   - Ensure the toolchain paths in `build_kernel.sh` are correct
   - The script expects clang and build-tools in `./toolchain/` directory

4. **Build the kernel**
   ```bash
   ./build_kernel.sh
   ```

   The build process will:
   - Use `hunter_defconfig` configuration
   - Compile for ARM64 architecture
   - Target SoC: s5e8535 (Exynos 1330)
   - Generate kernel Image, DTB, and DTBO

5. **Build artifacts location**
   
   After successful compilation, artifacts are in `out/` or the directory specified by your build config:
   - `arch/arm64/boot/Image` - Kernel image
   - `arch/arm64/boot/dts/exynos/s5e8535.dtb` - Device tree blob
   - `dtbo.img` - Device tree overlay image

---

## 📦 Creating AnyKernel3 Flashable ZIP

### What is AnyKernel3?

AnyKernel3 is a template for creating flashable kernel ZIPs that can be installed via custom recovery (TWRP, OrangeFox, etc.). It safely unpacks, patches, and repacks boot images.

### Generate ZIP Package

After building the kernel, create a flashable ZIP:

```bash
./scripts/package_anykernel3.sh
```

**Available options:**
```bash
./scripts/package_anykernel3.sh [OPTIONS]

Options:
  -h, --help              Show help message
  -o, --out-dir DIR       Specify kernel output directory (default: ./out)
  -d, --dist-dir DIR      Specify distribution directory for ZIP (default: ./dist)
  -n, --name NAME         Custom ZIP filename
  --boot                  Target boot partition (default)
  --vendor-boot           Target vendor_boot partition
```

**Example:**
```bash
# Basic usage (uses default paths)
./scripts/package_anykernel3.sh

# Custom output directory
./scripts/package_anykernel3.sh -o out/kernel -d releases

# Custom ZIP name
./scripts/package_anykernel3.sh -n "MyCustomKernel-$(date +%Y%m%d).zip"
```

The ZIP will be created in `dist/` directory by default.

---

## 💾 Installation Requirements

### Before Flashing

**CRITICAL: Always create backups before flashing!**

1. **Custom Recovery Required**
   - TWRP (Team Win Recovery Project)
   - OrangeFox Recovery
   - Other Android-compatible custom recovery

2. **Unlocked Bootloader**
   - Your device bootloader must be unlocked
   - WARNING: Unlocking bootloader will wipe your data!

3. **Full Backup**
   - Create a full NANDROID backup in recovery
   - Backup your boot partition specifically
   - Backup important data to external storage/cloud

4. **Charge Battery**
   - Ensure at least 50% battery before flashing
   - Have your charger nearby

### Installation Steps

1. **Boot into Recovery**
   - Power off device
   - Hold Volume Up + Power button
   - Select Recovery from boot menu

2. **Flash the ZIP**
   ```
   Install → Select ZIP → Choose AnyKernel3-*.zip → Swipe to flash
   ```

3. **Verify Device Model**
   - The installer will automatically check device model
   - Only SM-A146B and SM-A146M are supported
   - Installation will abort if device model doesn't match

4. **Post-flash**
   - Wipe cache/dalvik (recommended)
   - Reboot system

5. **Verify Installation**
   - Check kernel version in Settings → About Phone
   - Look for custom kernel name/version

### If Something Goes Wrong

- **Boot loop:** Flash stock boot.img or restore NANDROID backup
- **No boot:** Flash stock firmware via Odin/Heimdall
- **Random reboots:** Restore stock kernel, kernel may be unstable

---

## 🔄 Device Compatibility (A146B vs A146M)

### Supported Models

- ✅ **SM-A146B** - International variant (PRIMARY)
- ✅ **SM-A146M** - Latin America variant (COMPATIBLE)

### Understanding the Variants

Both SM-A146B and SM-A146M use the **same Exynos 1330 (s5e8535) SoC** and share most hardware specifications. However, there are subtle differences:

#### Hardware Differences

| Component | Impact Level | Details |
|-----------|-------------|---------|
| **Kernel/SoC** | ✅ NONE | Identical Exynos 1330, same kernel works for both |
| **DTB/DTBO** | ⚠️ LOW | Minor device tree variations |
| **Modem/Baseband** | ⚠️ MEDIUM | Different radio bands and modem firmware |
| **CSC Code** | ℹ️ INFO | Different country/carrier settings |
| **Partition Layout** | ✅ NONE | Identical partition structure |

#### Flashing Between Variants

**Can I flash A146B kernel on A146M (or vice versa)?**

✅ **YES, with caveats:**

1. **Kernel level:** Fully compatible - same SoC, same kernel
2. **Device Tree:** Generally compatible, minor differences exist
3. **Risk Level:** LOW - Most functions will work

**Potential Issues:**

⚠️ **Possible (but rare):**
- Slightly different sensor behavior
- Minor GPIO differences
- Some hardware features may need variant-specific DTB tweaks

❌ **NOT affected:**
- Modem/baseband (handled by separate firmware)
- CSC/carrier settings (separate partition)
- Bootloader compatibility

#### Recommendations

**For SM-A146B users:**
- ✅ Use as-is, fully tested

**For SM-A146M users:**
- ✅ Generally safe to use
- ⚠️ Test all hardware features after flashing:
  - Sensors (accelerometer, proximity, etc.)
  - Camera
  - Audio
  - Fingerprint
  - NFC (if equipped)
- 📱 Keep stock boot.img backup for quick recovery

**Important:** While the kernel is compatible, if you experience hardware issues specific to your variant, please report them as they may require DTB adjustments.

---

## ⚙️ Kernel Tuning Options

This section covers various kernel tuning options available through configuration or runtime modification. **Always test changes and measure results before daily use.**

### Safety Levels

- 🟢 **SAFE** - Well-tested, minimal risk
- 🟡 **MODERATE** - Test before daily use, may affect stability
- 🔴 **RISKY** - Expert users only, potential for instability/boot issues

### CPU Governor Tuning

**What it does:** Controls CPU frequency scaling policy

**Location:** `/sys/devices/system/cpu/cpu*/cpufreq/scaling_governor`

**Available governors** (depends on kernel config):
- 🟢 `schedutil` (default) - Modern, scheduler-integrated, balanced
- 🟢 `interactive` - Responsive, good for UI
- 🟡 `performance` - Maximum performance, high battery drain
- 🟡 `powersave` - Battery saver, may feel sluggish
- 🟡 `conservative` - Gradual frequency scaling

**Example:**
```bash
# Set performance governor (root required)
echo performance > /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

**Recommendation:** 🟢 Keep default `schedutil` for best balance

### I/O Scheduler

**What it does:** Controls how disk I/O requests are ordered

**Location:** `/sys/block/*/queue/scheduler`

**Common schedulers:**
- 🟢 `mq-deadline` (default) - Good for flash storage
- 🟢 `noop/none` - Minimal overhead, good for SSDs
- 🟡 `cfq` - Fair queuing, better for HDDs
- 🟡 `bfq` - Desktop-like responsiveness

**Example:**
```bash
# Check current scheduler
cat /sys/block/sda/queue/scheduler

# Set scheduler
echo mq-deadline > /sys/block/sda/queue/scheduler
```

**Recommendation:** 🟢 Default is optimized for UFS/eMMC storage

### ZRAM Configuration

**What it does:** Compressed RAM swap for better multitasking

**Location:** `/sys/block/zram0/`

**Tuning parameters:**
- `disksize` - ZRAM size (default: ~1GB)
- `comp_algorithm` - Compression algorithm (lz4, lzo, zstd)

**Example:**
```bash
# Check current ZRAM config
cat /sys/block/zram0/disksize
cat /sys/block/zram0/comp_algorithm

# Modify (requires root and swapoff first)
swapoff /dev/block/zram0
echo lz4 > /sys/block/zram0/comp_algorithm
echo 2G > /sys/block/zram0/disksize
mkswap /dev/block/zram0
swapon /dev/block/zram0
```

**Recommendation:** 🟡 Default is balanced; increase for heavy multitasking

### TCP Congestion Control

**What it does:** Optimizes network throughput

**Location:** `/proc/sys/net/ipv4/tcp_congestion_control`

**Common algorithms:**
- 🟢 `cubic` (default) - Good general purpose
- 🟢 `bbr` - Google's modern algorithm, excellent for mobile
- 🟡 `westwood` - WiFi optimized

**Example:**
```bash
# Check available algorithms
cat /proc/sys/net/ipv4/tcp_available_congestion_control

# Set BBR
echo bbr > /proc/sys/net/ipv4/tcp_congestion_control
```

**Recommendation:** 🟢 Try `bbr` for better network performance

### Debug and Logging

**What it does:** Controls kernel logging verbosity

**Location:** `/proc/sys/kernel/printk`

🟡 **Reducing logs** (slight performance gain, harder debugging):
```bash
# Less verbose kernel logging
echo "3 3 3 3" > /proc/sys/kernel/printk
```

🟢 **Default/Debugging:**
```bash
# Verbose logging (default)
echo "7 4 1 7" > /proc/sys/kernel/printk
```

**Recommendation:** 🟢 Keep default unless you need maximum performance and don't debug

### Filesystem Optimizations

🟡 **Disable journaling** (RISKY - data loss on crash):
```bash
# NOT RECOMMENDED - can corrupt data on unexpected shutdown
# Only for testing/benchmarks
```

🟢 **Mount options** (via init scripts):
- `noatime` - Don't update access time (battery saving)
- `nodiratime` - Don't update directory access time

**Recommendation:** 🟢 Modern kernels already optimize this

### Advanced: Custom Kernel Build Options

For compile-time tuning, modify `arch/arm64/configs/hunter_defconfig`:

🟢 **Safe options:**
- `CONFIG_HZ_300=y` - Increase timer frequency (smoother UI, slight battery impact)
- `CONFIG_NO_HZ_FULL=y` - Tickless kernel for better efficiency
- `CONFIG_PREEMPT=y` - Better desktop-like responsiveness

🔴 **Risky options:**
- `CONFIG_LOCALVERSION` - Change kernel name
- Overclocking options (if available) - Can damage hardware
- Custom scheduler patches - May cause instability

### Measurement and Testing

**Always measure before/after changes:**

1. **Battery life:** Use AccuBattery or similar
2. **Performance:** AnTuTu, Geekbench
3. **Stability:** Use device normally for 24-48 hours
4. **Temperature:** Monitor with CPU monitoring apps

**If you experience issues:**
- Revert changes one by one
- Boot to recovery, restore backup
- Flash stock kernel if needed

### Automation

Use Kernel Manager apps (root required):
- **Franco Kernel Manager**
- **HKTweaks**
- **EX Kernel Manager**

These apps provide GUI for tuning and can apply settings on boot.

---

## 🔧 Troubleshooting

### Build Issues

**Problem:** Toolchain not found
```bash
Solution: Update paths in build_kernel.sh to match your toolchain location
```

**Problem:** Out of memory during build
```bash
Solution: Reduce parallel jobs: make -j4 (instead of -j$(nproc))
```

**Problem:** Missing dependencies
```bash
Solution: Install build essentials
sudo apt-get install build-essential bc bison flex libssl-dev libncurses-dev
```

### Flashing Issues

**Problem:** "Device not supported" error
```bash
Solution: This kernel is only for SM-A146B/M. Verify your device model.
```

**Problem:** Stuck on boot logo
```bash
Solution: 
1. Boot to recovery
2. Restore boot backup or flash stock boot.img
3. Check if you flashed correct variant
```

### Runtime Issues

**Problem:** Random reboots
```bash
Possible causes:
- Unstable overclock settings
- Incompatible kernel modifications
- Hardware-specific DTB issues (rare on A146M)

Solution: Flash stock kernel, restore defaults
```

**Problem:** Features not working (sensors, camera, etc.)
```bash
For SM-A146M users: May indicate DTB incompatibility
Solution: Report the issue with detailed logs
```

---

## 📝 Contributing

Contributions are welcome! Please:
1. Test thoroughly on real hardware
2. Document changes clearly
3. Submit pull requests with detailed descriptions

---

## ⚠️ Disclaimer

- Flashing custom kernels voids warranty
- You are solely responsible for any damage to your device
- Always keep backups
- This kernel is provided AS-IS with no guarantees

---

## 📜 License

This kernel is based on Linux kernel and follows GPL v2 license. See COPYING file for details.

KernelSU integration follows its respective license.

---

## 🙏 Credits

- HunterGaming1212 (Github)
- Samsung for kernel sources
- KernelSU developers
- osm0sis for AnyKernel3
- XDA community

---

## Device pictures

![Samsung A14 5G](https://images.samsung.com/is/image/samsung/p6pim/latin_en/sm-a146mzkdtpa/gallery/latin-en-galaxy-a14-5g-sm-a146-sm-a146mzkdtpa-535153806?$365_292_PNG$ "Black")
![Samsung A14 5G](https://images.samsung.com/is/image/samsung/p6pim/latin_en/sm-a146mlgdtpa/gallery/latin-en-galaxy-a14-5g-sm-a146-sm-a146mlgdtpa-535153768?$365_292_PNG$ "Green")
![Samsung A14 5G](https://images.samsung.com/is/image/samsung/p6pim/latin_en/sm-a146mzsgtpa/gallery/latin-en-galaxy-a14-5g-sm-a146-sm-a146mzsgtpa-535153863?$365_292_PNG$ "Silver")
