#!/sbin/sh
# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

## AnyKernel setup
# begin properties
properties() { '
kernel.string=SM-A146B/M KernelSU Kernel by narutojgdr-sudo
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=a14x
device.name2=SM-A146B
device.name3=SM-A146M
device.name4=a14xdx
device.name5=
supported.versions=13-14
supported.patchlevels=
'; } # end properties

# shell variables
block=auto;
is_slot_device=auto;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel boot install
split_boot; # use split_boot to skip ramdisk unpack, e.g. for devices with init_boot

# Detect actual model
actual_model=$(getprop ro.product.model);
actual_device=$(getprop ro.product.device);

ui_print " ";
ui_print "Detected device model: $actual_model";
ui_print "Detected device name: $actual_device";
ui_print " ";

# Verify device compatibility
case "$actual_model" in
  SM-A146B|SM-A146M)
    ui_print "Device verified: $actual_model";
    ui_print " ";
    ;;
  *)
    ui_print "WARNING: Unsupported device model: $actual_model";
    ui_print "This kernel is designed for SM-A146B/M only!";
    ui_print " ";
    ui_print "Supported models:";
    ui_print "  - SM-A146B (International)";
    ui_print "  - SM-A146M (Latin America)";
    ui_print " ";
    ui_print "Installation aborted for safety.";
    exit 1;
    ;;
esac;

# Warn about variant-specific risks
case "$actual_model" in
  SM-A146M)
    ui_print "NOTE: SM-A146M detected";
    ui_print "While generally compatible with SM-A146B,";
    ui_print "there may be minor DTB/DTBO differences.";
    ui_print "Ensure you have a backup!";
    ui_print " ";
    ;;
esac;

# Flash kernel image
flash_boot;
flash_dtbo;

## end boot install

## vendor_boot files
# This section is for vendor_boot ramdisk modifications if needed
# For now, we keep it minimal as the kernel is in boot partition

## Cleanup and finish
write_boot; # use write_boot to skip ramdisk repack, e.g. for devices with init_boot
## end vendor_boot install
