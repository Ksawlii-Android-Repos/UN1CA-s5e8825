FLOPPY_VER="4.3"
FLOPPY_BUILD_DATE="20250411-1642"
FLOPPY_ZIP="https://github.com/FlopKernel-Series/flop_s5e8825_kernel/releases/download/flop-v$FLOPPY_VER/Floppy_v$FLOPPY_VER-Vanilla-exynos1280-$FLOPPY_BUILD_DATE.tar"

# [
REPLACE_KERNEL_BINARIES()
{
    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
    mkdir -p "$TMP_DIR"

    echo "Downloading $(basename "$FLOPPY_ZIP")"
    curl -L -s -o "$TMP_DIR/floppy.tar" "$FLOPPY_ZIP"

    echo "Extracting kernel binaries"
    [ -f "$WORK_DIR/kernel/boot.img" ] && rm -rf "$WORK_DIR/kernel/boot.img"
    [ -f "$WORK_DIR/kernel/vendor_boot.img" ] && rm -rf "$WORK_DIR/kernel/vendor_boot.img"
    mkdir "$WORK_DIR/floppy"
    tar xf "$TMP_DIR/floppy.tar" -C "$WORK_DIR/floppy"
    lz4 -q -d "$WORK_DIR/floppy/boot.img.lz4" "$WORK_DIR/floppy/boot.img"
    lz4 -q -d "$WORK_DIR/floppy/vendor_boot.img.lz4" "$WORK_DIR/floppy/vendor_boot.img"
    echo "Replacing kernel binaries"
    mv "$WORK_DIR/floppy/boot.img" "$WORK_DIR/floppy/vendor_boot.img" "$WORK_DIR/kernel/"
}
# ]

if [ "$TARGET_CODENAME" != "m34x" ]; then
    REPLACE_KERNEL_BINARIES
    rm -rf "$TMP_DIR"
    rm -rf "$WORK_DIR/floppy/"  
fi
