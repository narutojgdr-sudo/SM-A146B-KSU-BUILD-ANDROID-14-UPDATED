# AnyKernel3 Packaging Documentation

This document provides detailed information about the AnyKernel3 packaging structure and customization for the SM-A146B/M kernel.

## 📁 Directory Structure

```
packaging/anykernel3/
├── META-INF/
│   └── com/google/android/
│       ├── update-binary          # AnyKernel3 backend/installer
│       └── updater-script         # Magisk compatibility marker
├── tools/
│   ├── ak3-core.sh               # Core AnyKernel3 functions
│   └── README.txt                # Tools documentation
└── anykernel.sh                   # Device-specific configuration
```

## 🔧 Configuration (anykernel.sh)

### Device Properties

```bash
kernel.string=SM-A146B/M KernelSU Kernel by narutojgdr-sudo
do.devicecheck=1                   # Enable device verification
do.modules=0                       # No kernel modules in ZIP
do.systemless=1                    # Systemless installation (Magisk/KSU compatible)
do.cleanup=1                       # Clean up after installation
do.cleanuponabort=0               # Keep files if installation fails
```

### Supported Devices

The installer checks for these device identifiers:

```bash
device.name1=a14x                  # Device codename
device.name2=SM-A146B             # International model
device.name3=SM-A146M             # Latin America model
device.name4=a14xdx               # Alternative codename
```

### Android Version Support

```bash
supported.versions=13-14           # Android 13 and 14
supported.patchlevels=            # All patch levels (empty = all)
```

## 🎯 Boot/Vendor Boot Detection

The kernel targets the **boot** partition by default, as determined from the build configuration:

- `BUILD_BOOT_IMG=1` in `build.config.erd8535_t`
- `BOOT_IMAGE_HEADER_VERSION=4`

### Partition Target

The AnyKernel3 script uses:
```bash
block=auto;                        # Auto-detect boot partition
is_slot_device=auto;              # Auto-detect A/B slots
```

This automatically:
1. Detects if device uses A/B partitioning (this device does)
2. Finds the correct boot partition (`/dev/block/by-name/boot_a` or `boot_b`)
3. Flashes to the active slot

## 🔍 Device Verification

During installation, the script performs these checks:

### 1. Model Detection

```bash
actual_model=$(getprop ro.product.model);
actual_device=$(getprop ro.product.device);
```

Reads Android system properties to identify the device.

### 2. Compatibility Check

Only allows installation on:
- SM-A146B
- SM-A146M

Aborts installation for any other model to prevent bricks.

### 3. Variant Warning

For SM-A146M users, displays a warning about potential DTB/DTBO differences.

## 📦 Build Artifacts Included

### Required Files

1. **Image** - Kernel binary
   - Source: `arch/arm64/boot/Image`
   - Size: ~25-35 MB
   - Format: Uncompressed ARM64 kernel

2. **DTB** (Device Tree Blob) - Optional but recommended
   - Source: `arch/arm64/boot/dts/exynos/s5e8535.dtb`
   - Size: ~1-2 MB
   - Contains hardware configuration

3. **DTBO** (Device Tree Overlay) - Optional but recommended
   - Source: `dtbo.img`
   - Size: ~1-2 MB
   - Contains device-specific overlays

### How They're Included

The `package_anykernel3.sh` script:
1. Copies `Image` from `out/` directory
2. Copies `dtb` if found
3. Copies `dtbo.img` if found
4. Packages everything into a flashable ZIP

## 🛠️ Customization Guide

### Change Kernel Name

Edit `packaging/anykernel3/anykernel.sh`:

```bash
kernel.string=Your Custom Kernel Name
```

### Add Custom Banner

Create `packaging/anykernel3/banner`:

```
╔═══════════════════════════════════════╗
║   My Custom Kernel for Galaxy A14     ║
║   Version 1.0 - Built with ❤️        ║
╚═══════════════════════════════════════╝
```

### Add More Device Models

Edit device names in `anykernel.sh`:

```bash
device.name5=SM-A146U              # US variant (if compatible)
device.name6=another_model
```

**Warning:** Only add models you've tested! Incompatible models may brick.

### Change Supported Android Versions

```bash
supported.versions=12-15           # Support Android 12-15
supported.patchlevels=2024-01      # Require specific patch level
```

### Add Pre/Post-Installation Scripts

In `anykernel.sh`, before `write_boot;`:

```bash
# Example: Set SELinux to permissive
ui_print "Setting SELinux to permissive...";
setenforce 0;

# Example: Create a flag file
ui_print "Creating boot flag...";
touch /data/local/tmp/custom_kernel_installed;
```

## 🔬 Technical Details

### Boot Image Structure

The device uses Boot Image Header Version 4, which has:

```
┌─────────────────────┐
│   Boot Header       │
├─────────────────────┤
│   Kernel (Image)    │
├─────────────────────┤
│   Ramdisk           │
├─────────────────────┤
│   DTB               │
└─────────────────────┘
```

AnyKernel3 operations:
1. **Unpack** boot image using `magiskboot` or similar tool
2. **Replace** kernel Image and DTB
3. **Keep** original ramdisk (preserves init and modules)
4. **Repack** boot image with new kernel
5. **Flash** to boot partition

### DTBO Handling

DTBO is stored in a separate partition (`dtbo`):

```bash
flash_dtbo;  # Flashes dtbo.img to /dev/block/by-name/dtbo
```

This is independent of the boot image.

### A/B Slot Handling

For A/B devices (like SM-A146B/M):

```bash
# AnyKernel3 automatically:
1. Detects active slot (getprop ro.boot.slot_suffix)
2. Flashes to active slot (boot_a or boot_b)
3. Updates boot marker if needed
```

## 🧪 Testing the Package

### Local Testing (Without Device)

1. **Check ZIP structure**:
   ```bash
   unzip -l dist/AnyKernel3-*.zip
   ```

   Should contain:
   - `META-INF/com/google/android/update-binary`
   - `META-INF/com/google/android/updater-script`
   - `anykernel.sh`
   - `tools/ak3-core.sh`
   - `Image`
   - `dtb` (if included)
   - `dtbo.img` (if included)

2. **Verify file permissions**:
   ```bash
   zipinfo -l dist/AnyKernel3-*.zip | grep -E "(anykernel|update-binary|ak3-core)"
   ```

   Scripts should have execute permissions.

3. **Check anykernel.sh syntax**:
   ```bash
   bash -n packaging/anykernel3/anykernel.sh
   ```

### Device Testing

**CRITICAL: Always test on a device you can afford to brick!**

1. **Create full backup** (TWRP/OrangeFox)
2. **Flash the ZIP**
3. **Check recovery log**:
   - Device detection should show correct model
   - No errors during unpacking/repacking
   - Boot image flashed successfully
4. **Boot the device**
5. **Verify kernel**: `uname -r` in terminal

### Troubleshooting Packaging Issues

**Problem:** ZIP too large (>50MB)
```bash
# Check what's included
unzip -l dist/AnyKernel3-*.zip | sort -k4 -n -r | head -20

# Likely causes:
# - Accidentally included build artifacts
# - Large unnecessary files in packaging/anykernel3/
```

**Problem:** Installation aborted immediately
```bash
# Check recovery log for:
# - Unzip errors (corrupt ZIP)
# - Missing files (update-binary, anykernel.sh)
# - Permission errors (files not executable)
```

**Problem:** Device not detected
```bash
# In recovery, check:
getprop ro.product.model
getprop ro.product.device

# Update device.name* in anykernel.sh accordingly
```

## 📚 Advanced: Boot vs Vendor Boot

### Current Configuration: BOOT

This kernel uses **boot** partition, as indicated by:

```bash
BUILD_BOOT_IMG=1                  # From build.config.erd8535_t
KERNEL_BINARY=Image              # Kernel goes in boot
```

### If Using VENDOR_BOOT (Not Current Setup)

If Samsung ever moves to vendor_boot kernel (GKI 2.0 style):

Edit `anykernel.sh`:
```bash
# Add vendor_boot handling
split_boot;
flash_boot;
flash_dtbo;

# Would become:
split_boot;
flash_boot;              # For ramdisk
split_vendor_boot;
flash_vendor_boot;       # For kernel
flash_dtbo;
```

Update `package_anykernel3.sh` to include vendor_boot artifacts.

## 🔗 References

- [AnyKernel3 Official](https://github.com/osm0sis/AnyKernel3)
- [Android Boot Image Format](https://source.android.com/docs/core/architecture/bootloader/boot-image-header)
- [Device Tree Documentation](https://www.kernel.org/doc/html/latest/devicetree/usage-model.html)

## 📋 Checklist for Package Release

Before releasing a kernel package:

- [ ] Kernel builds without errors
- [ ] All required artifacts present (Image, DTB, DTBO)
- [ ] AnyKernel3 ZIP created successfully
- [ ] ZIP structure verified
- [ ] Device detection tested on real hardware
- [ ] Boots successfully on SM-A146B
- [ ] Boots successfully on SM-A146M (if tested)
- [ ] All hardware features working (sensors, camera, etc.)
- [ ] Performance tested (benchmarks, stability)
- [ ] Battery life acceptable
- [ ] Documentation updated (README, changelog)
- [ ] Version/date in ZIP filename

## 🆘 Support

If you encounter issues with packaging:

1. Check this documentation
2. Verify build artifacts are generated correctly
3. Test with stock build first
4. Check XDA forums for similar issues
5. Open an issue with detailed logs

---

**Remember:** The goal of AnyKernel3 is to make kernel flashing safe and reproducible. Always test thoroughly!
