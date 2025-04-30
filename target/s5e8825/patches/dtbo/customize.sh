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

APPLY_PATCH() {
    local PATCH
    local COMMIT_NAME

    PATCH="$SRC_DIR/target/s5e8825/patches/dtbo/patches/$2"
    COMMIT_NAME="$(grep "^Subject:" "$PATCH" | sed 's/.*PATCH] //')"
    echo "Applying \"$COMMIT_NAME\" to $1"
    patch -p1 -s -t -N --no-backup-if-mismatch -d "$TMP_DIR" < "$PATCH" &> /dev/null
    cd - &> /dev/null
}

CREATE_CFG() {
  if [ "$TARGET_CODENAME" = "a53x" ]; then
      cat << EOF > "$TMP_DIR/a53x.cfg"
a53x_eur_open_w00_r00.dtbo
    custom0=0x00000000
    custom1=0x00000000

a53x_eur_open_w00_r01.dtbo
    custom0=0x00000001
    custom1=0x00000001

a53x_eur_open_w00_r02.dtbo
    custom0=0x00000002
    custom1=0x00000004

a53x_eur_open_w00_r05.dtbo
    custom0=0x00000005
    custom1=0x00000005

a53x_eur_open_w00_r06.dtbo
    custom0=0x00000006
    custom1=0x00000020
EOF
    elif [ "$TARGET_CODENAME" = "a25x" ]; then
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
    elif [ "$TARGET_CODENAME" = "m34x" ]; then
        cat << EOF > "$TMP_DIR/m34x.cfg"
m34x_eur_open_w00_r00.dtbo
    custom0=0x00000000
    custom1=0x00000000

m34x_eur_open_w00_r01.dtbo
    custom0=0x00000001
    custom1=0x00000020
EOF
    fi
}

PACK_TO_DTBO() {
    if [ "$TARGET_CODENAME" = "a53x" ]; then
        dtc -I dts -O dtb -o "$TMP_DIR/a53x_eur_open_w00_r00.dtbo" "$TMP_DIR/dtsi.0" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a53x_eur_open_w00_r01.dtbo" "$TMP_DIR/dtsi.1" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a53x_eur_open_w00_r02.dtbo" "$TMP_DIR/dtsi.2" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a53x_eur_open_w00_r05.dtbo" "$TMP_DIR/dtsi.3" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a53x_eur_open_w00_r06.dtbo" "$TMP_DIR/dtsi.4" &> /dev/null
    elif [ "$TARGET_CODENAME" = "a25x" ]; then
        dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r00.dtbo" "$TMP_DIR/dtsi.0" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r04.dtbo" "$TMP_DIR/dtsi.1" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/a25x_swa_open_w00_r05.dtbo" "$TMP_DIR/dtsi.2" &> /dev/null
    elif [ "$TARGET_CODENAME" = "m34x" ]; then
        dtc -I dts -O dtb -o "$TMP_DIR/m34x_eur_open_w00_r00.dtbo" "$TMP_DIR/dtsi.0" &> /dev/null
        dtc -I dts -O dtb -o "$TMP_DIR/m34x_eur_open_w00_r01.dtbo" "$TMP_DIR/dtsi.1" &> /dev/null
    fi
}

PACK_TO_IMG() {
    mkdtimg cfg_create "$TMP_DIR/dtbo.img" "$TMP_DIR/$TARGET_CODENAME.cfg" -d "$TMP_DIR" &> /dev/null
}

echo "Extracting dtbo"
EXTRACT
if [ "$TARGET_CODENAME" = "a53x" ]; then
    APPLY_PATCH "dtbo" "0001-Fix-Adaptive-Refresh-Rate-Color-Flickering-a53x.patch" 
elif [ "$TARGET_CODENAME" = "a25x" ]; then
    APPLY_PATCH "dtbo" "0001-Fix-Adaptive-Refresh-Rate-Color-Flickering-a25x.patch"
elif [ "$TARGET_CODENAME" = "m34x" ]; then
    APPLY_PATCH "dtbo" "0001-Fix-Adaptive-Refresh-Rate-Color-Flickering-m34x.patch"
fi
CREATE_CFG
echo "Repacking dtbo"
PACK_TO_DTBO
PACK_TO_IMG
[ -f "$WORK_DIR/kernel/dtbo.img" ] && rm -rf "$WORK_DIR/kernel/dtbo.img"
echo "Copying new dtbo.img"
cp -fa "$TMP_DIR/dtbo.img" "$WORK_DIR/kernel/dtbo.img"
rm -rf "$TMP_DIR"
