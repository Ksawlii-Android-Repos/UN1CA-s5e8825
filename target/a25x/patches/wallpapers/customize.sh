LOG_STEP_IN
LOG "- Fix Live Wallpapers"
ADD_TO_WORK_DIR "e1qzcx" "system" "system/priv-app/wallpaper-res/wallpaper-res.apk" 0 0 644 "u:object_r:system_file:s0"
DECODE_APK "system" "system/priv-app/wallpaper-res/wallpaper-res.apk"
cp -fa "$SRC_DIR/target/$TARGET_CODENAME/patches/wallpapers/mp4/"* \
       "$APKTOOL_DIR/system/priv-app/wallpaper-res/wallpaper-res.apk/res/raw/"
LOG_STEP_OUT
