# Quick Start Guide - SM-A146B/M Custom Kernel

This is a quick reference for building and flashing the custom kernel. For detailed information, see [README.md](README.md).

## 🚀 Quick Build

```bash
# 1. Clone repository
git clone https://github.com/narutojgdr-sudo/SM-A146B-KSU-BUILD-ANDROID-14-UPDATED.git
cd SM-A146B-KSU-BUILD-ANDROID-14-UPDATED

# 2. Build kernel
./build_kernel.sh

# 3. Package for flashing
./scripts/package_anykernel3.sh

# Output: dist/AnyKernel3-SM-A146B-KSU-*.zip
```

## ⚡ Quick Flash

```bash
# In custom recovery (TWRP/OrangeFox):
1. Backup boot partition
2. Install → Select ZIP
3. Choose AnyKernel3-*.zip
4. Swipe to flash
5. Reboot
```

## ⚠️ Important

- ✅ **SM-A146B** - Fully tested
- ✅ **SM-A146M** - Compatible, minor caveats
- ❌ **Other models** - NOT supported, will brick!

## 📱 Device Check

Before flashing, verify your device model:

```bash
# In ADB or terminal
getprop ro.product.model
# Should show: SM-A146B or SM-A146M
```

## 🔧 Build Requirements

- Linux system (Ubuntu/Debian recommended)
- 16GB+ RAM
- 50GB+ free space
- Toolchains in `./toolchain/` directory

## 📦 Package Contents

The AnyKernel3 ZIP includes:
- Kernel Image (ARM64)
- Device Tree Blob (DTB)
- Device Tree Overlay (DTBO)
- Installer scripts with device verification

## 🆘 Troubleshooting

**Build fails?**
- Check toolchain paths in `build_kernel.sh`
- Ensure 16GB+ RAM available

**Flash fails?**
- Verify device model is SM-A146B/M
- Use compatible recovery (TWRP)
- Check if bootloader is unlocked

**Boot loop?**
- Flash stock boot.img in recovery
- Or restore NANDROID backup

## 📚 Documentation

- [README.md](README.md) - Full documentation
- [PACKAGING.md](PACKAGING.md) - AnyKernel3 technical details
- [CHANGELOG.md](CHANGELOG.md) - Version history

## 🔗 Resources

- **Kernel Source**: This repository
- **KernelSU**: [GitHub](https://github.com/tiann/KernelSU)
- **AnyKernel3**: [GitHub](https://github.com/osm0sis/AnyKernel3)
- **XDA Forum**: (Add link if exists)

## 💡 Tips

1. **Always backup** before flashing
2. **Test stability** for 24-48 hours
3. **Monitor temperature** with kernel manager apps
4. **Report issues** with detailed logs

---

**Happy flashing! 📱⚡**
