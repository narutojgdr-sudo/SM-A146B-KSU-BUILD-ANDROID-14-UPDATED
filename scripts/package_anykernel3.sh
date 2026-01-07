#!/bin/bash
# AnyKernel3 Packaging Script for SM-A146B/M
# This script packages the kernel build artifacts into an AnyKernel3 flashable ZIP

set -e

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
KERNEL_ROOT="$(dirname "$SCRIPT_DIR")"
AK3_TEMPLATE="$KERNEL_ROOT/packaging/anykernel3"
OUT_DIR="${OUT_DIR:-$KERNEL_ROOT/out}"
DIST_DIR="${DIST_DIR:-$KERNEL_ROOT/dist}"

# Kernel artifacts (based on build.config.erd8535_t)
KERNEL_IMAGE="arch/arm64/boot/Image"
DTB_IMAGE="arch/arm64/boot/dts/exynos/s5e8535.dtb"
DTBO_IMAGE="dtbo.img"

# Build timestamp
BUILD_DATE=$(date +%Y%m%d-%H%M)
KERNEL_VERSION=$(cat "$KERNEL_ROOT/Makefile" | grep "^VERSION = " | awk '{print $3}')
PATCHLEVEL=$(cat "$KERNEL_ROOT/Makefile" | grep "^PATCHLEVEL = " | awk '{print $3}')
SUBLEVEL=$(cat "$KERNEL_ROOT/Makefile" | grep "^SUBLEVEL = " | awk '{print $3}')
KERNEL_VER="${KERNEL_VERSION}.${PATCHLEVEL}.${SUBLEVEL}"

# Output ZIP name
ZIP_NAME="AnyKernel3-SM-A146B-KSU-${KERNEL_VER}-${BUILD_DATE}.zip"

# Help message
show_help() {
    echo -e "${BLUE}AnyKernel3 Packaging Script for SM-A146B/M${NC}"
    echo ""
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help              Show this help message"
    echo "  -o, --out-dir DIR       Specify kernel output directory (default: \$OUT_DIR or ./out)"
    echo "  -d, --dist-dir DIR      Specify distribution directory for ZIP (default: \$DIST_DIR or ./dist)"
    echo "  -n, --name NAME         Custom ZIP filename (default: auto-generated)"
    echo "  --boot                  Target boot partition (default, auto-detected)"
    echo "  --vendor-boot           Target vendor_boot partition"
    echo ""
    echo "Example:"
    echo "  $0 -o out/kernel -d dist"
    echo ""
}

# Parse arguments
PARTITION_TARGET="auto"
CUSTOM_ZIP_NAME=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -o|--out-dir)
            OUT_DIR="$2"
            shift 2
            ;;
        -d|--dist-dir)
            DIST_DIR="$2"
            shift 2
            ;;
        -n|--name)
            CUSTOM_ZIP_NAME="$2"
            shift 2
            ;;
        --boot)
            PARTITION_TARGET="boot"
            shift
            ;;
        --vendor-boot)
            PARTITION_TARGET="vendor_boot"
            shift
            ;;
        *)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
    esac
done

# Use custom name if provided
if [ -n "$CUSTOM_ZIP_NAME" ]; then
    ZIP_NAME="$CUSTOM_ZIP_NAME"
fi

echo -e "${BLUE}========================================${NC}"
echo -e "${BLUE}  AnyKernel3 Package Builder${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo -e "${GREEN}Configuration:${NC}"
echo "  Kernel Root:    $KERNEL_ROOT"
echo "  Output Dir:     $OUT_DIR"
echo "  Dist Dir:       $DIST_DIR"
echo "  ZIP Name:       $ZIP_NAME"
echo "  Partition:      $PARTITION_TARGET"
echo ""

# Verify AnyKernel3 template exists
if [ ! -d "$AK3_TEMPLATE" ]; then
    echo -e "${RED}Error: AnyKernel3 template not found at $AK3_TEMPLATE${NC}"
    exit 1
fi

# Verify kernel artifacts exist
echo -e "${YELLOW}Checking kernel artifacts...${NC}"

if [ ! -f "$OUT_DIR/$KERNEL_IMAGE" ]; then
    echo -e "${RED}Error: Kernel image not found: $OUT_DIR/$KERNEL_IMAGE${NC}"
    echo "Please build the kernel first using: ./build_kernel.sh"
    exit 1
fi
echo -e "${GREEN}✓${NC} Found kernel image: $KERNEL_IMAGE"

if [ ! -f "$OUT_DIR/$DTB_IMAGE" ]; then
    echo -e "${YELLOW}Warning: DTB image not found: $OUT_DIR/$DTB_IMAGE${NC}"
    echo "  Will continue without DTB"
    DTB_IMAGE=""
else
    echo -e "${GREEN}✓${NC} Found DTB image: $DTB_IMAGE"
fi

if [ ! -f "$OUT_DIR/$DTBO_IMAGE" ]; then
    echo -e "${YELLOW}Warning: DTBO image not found: $OUT_DIR/$DTBO_IMAGE${NC}"
    echo "  Will continue without DTBO"
    DTBO_IMAGE=""
else
    echo -e "${GREEN}✓${NC} Found DTBO image: $DTBO_IMAGE"
fi

# Create temporary build directory
TEMP_DIR=$(mktemp -d)
trap "rm -rf $TEMP_DIR" EXIT

echo ""
echo -e "${YELLOW}Creating package in temporary directory...${NC}"

# Copy AnyKernel3 template
cp -r "$AK3_TEMPLATE"/* "$TEMP_DIR/"

# Copy kernel image
echo -e "${GREEN}Copying kernel image...${NC}"
cp "$OUT_DIR/$KERNEL_IMAGE" "$TEMP_DIR/Image"

# Copy DTB if exists
if [ -n "$DTB_IMAGE" ] && [ -f "$OUT_DIR/$DTB_IMAGE" ]; then
    echo -e "${GREEN}Copying DTB image...${NC}"
    cp "$OUT_DIR/$DTB_IMAGE" "$TEMP_DIR/dtb"
fi

# Copy DTBO if exists
if [ -n "$DTBO_IMAGE" ] && [ -f "$OUT_DIR/$DTBO_IMAGE" ]; then
    echo -e "${GREEN}Copying DTBO image...${NC}"
    cp "$OUT_DIR/$DTBO_IMAGE" "$TEMP_DIR/dtbo.img"
fi

# Ensure scripts are executable
chmod +x "$TEMP_DIR/anykernel.sh"
chmod +x "$TEMP_DIR/META-INF/com/google/android/update-binary" 2>/dev/null || true
chmod +x "$TEMP_DIR/tools"/*.sh 2>/dev/null || true

# Create dist directory if it doesn't exist
mkdir -p "$DIST_DIR"

# Create ZIP
echo ""
echo -e "${YELLOW}Creating flashable ZIP...${NC}"
cd "$TEMP_DIR"
ZIP_PATH="$DIST_DIR/$ZIP_NAME"
zip -r9 "$ZIP_PATH" * -x '*.git*' -x 'README.txt' > /dev/null

# Verify ZIP was created
if [ ! -f "$ZIP_PATH" ]; then
    echo -e "${RED}Error: Failed to create ZIP file${NC}"
    exit 1
fi

ZIP_SIZE=$(du -h "$ZIP_PATH" | cut -f1)

echo ""
echo -e "${BLUE}========================================${NC}"
echo -e "${GREEN}✓ Package created successfully!${NC}"
echo -e "${BLUE}========================================${NC}"
echo ""
echo "  Output: $ZIP_PATH"
echo "  Size:   $ZIP_SIZE"
echo ""
echo -e "${YELLOW}Installation Notes:${NC}"
echo "  1. Boot into custom recovery (TWRP/OrangeFox)"
echo "  2. Create a backup of your current boot partition"
echo "  3. Flash the ZIP file"
echo "  4. Wipe cache/dalvik (optional but recommended)"
echo "  5. Reboot"
echo ""
echo -e "${RED}WARNING:${NC}"
echo "  - This is for SM-A146B/M devices only!"
echo "  - Flashing on other devices may brick your phone!"
echo "  - Always keep a backup before flashing!"
echo ""
echo -e "${GREEN}Done!${NC}"
