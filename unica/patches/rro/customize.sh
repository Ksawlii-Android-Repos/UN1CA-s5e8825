if [[ -d "$SRC_DIR/target/$TARGET_CODENAME/overlay" ]]; then
    DECODE_APK "/product/overlay/framework-res__auto_generated_rro_product.apk"

    echo "Applying stock overlay configs"
    rm -rf "$APKTOOL_DIR/product/overlay/framework-res__auto_generated_rro_product.apk/res"
    if [ "$TARGET_UNIFIED_NAME" != "false" ]; then
        mkdir -p "$APKTOOL_DIR/product/overlay/framework-res__auto_generated_rro_product.apk/res/overlay/"
        cp -a --preserve=all \
            "$SRC_DIR/target/$TARGET_UNIFIED_NAME/overlays/overlay-$TARGET_CODENAME"* \
            "$APKTOOL_DIR/product/overlay/framework-res__auto_generated_rro_product.apk/res/overlay/"
    else
        cp -a --preserve=all \
            "$SRC_DIR/target/$TARGET_CODENAME/overlay" \
            "$APKTOOL_DIR/product/overlay/framework-res__auto_generated_rro_product.apk/res"
    fi
fi
