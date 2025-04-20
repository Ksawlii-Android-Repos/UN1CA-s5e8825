set -e

SETUP_TOOLS() {
    cp -fa "target/a25x/patches/dtbo/tools/dtc" \
           "target/a25x/patches/dtbo/tools/mkdtimg" \
           "$TOOLS_DIR"
}

EXTRACT() {
    local DTB
    local DTS

    [ -d "$TMP_DIR" ] && rm -rf "$TMP_DIR"
     mkdir -p "$TMP_DIR"
    
    DTB="$TMP_DIR/dtb"
    DTS="$TMP_DIR/dtsi"
    mkdtimg dump "$WORK_DIR/kernel/dtbo.img" -b "$DTB" &> /dev/null

    for i in $(seq 0 19); do
        fi="${DTB}.${i}"
        fo="${DTS}.${i}"
        if [ -f "$fi" ]; then
            dtc -I dtb -O dts "$fi" -o "$fo" &> /dev/null
            rm "$fi"
        else
            break
        fi
    done
}

PACK_DTBO() {
    dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r00.dtbo" "$TMP_DIR/dtsi.0" &> /dev/null
    dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r04.dtbo" "$TMP_DIR/dtsi.1" &> /dev/null
    dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r05.dtbo" "$TMP_DIR/dtsi.2" &> /dev/null
}

CREATE_CFG() {
  cat << EOF > "$TMP_DIR/a25x.cfg"
a25x_swa_open_w00_r00.dtbo
    custom0=0x00000000
    custom1=0x00000003

a25x_swa_open_w00_r04.dtbo
    custom0=0x00000004
    custom1=0x00000004

a25x_swa_open_w00_r05.dtbo
    custom0=0x00000005
    custom1=0x00000020
EOF
}

APPLY_PATCH() {
    local PATCH
    local COMMIT_NAME

    PATCH="$SRC_DIR/target/a25x/patches/dtbo/patches/$2"
    COMMIT_NAME="$(grep "^Subject:" "$PATCH" | sed 's/.*PATCH] //')"
    echo "Applying \"$COMMIT_NAME\" to $1"
    patch -p1 -s -t -N --no-backup-if-mismatch -d "$TMP_DIR" < "$PATCH" &> /dev/null
    cd - &> /dev/null
}

REPACK() {
    mkdtimg cfg_create "$TMP_DIR/dtbo.img" "$TMP_DIR/a25x.cfg" -d "$TMP_DIR" &> /dev/null
}

echo "Extracting dtbo"
EXTRACT
APPLY_PATCH "dtbo" "0001-Fix-Adaptive-Refresh-Rate-Color-Flickering.patch"
CREATE_CFG
echo "Repacking dtbo"
PACK_DTBO
REPACK
[ -f "$WORK_DIR/kernel/dtbo.img" ] && rm -rf "$WORK_DIR/kernel/dtbo.img"
cp -fa "$TMP_DIR/dtbo.img" "$WORK_DIR/kernel/dtbo.img"
rm -rf "$TMP_DIR"
