echo "Fix Live Wallpapers"
ADD_TO_WORK_DIR "e1qzcx" "system" "system/priv-app/wallpaper-res/wallpaper-res.apk" 0 0 644 "u:object_r:system_file:s0"
DECODE_APK "/system/priv-app/wallpaper-res/wallpaper-res.apk"
cp -fa "target/$TARGET_COMMON_NAME/patches/wallpapers/mp4/Default_Video_Wallpaper_ZALG.mp4" \
      "target/$TARGET_COMMON_NAME/patches/wallpapers/mp4/Default_Video_Wallpaper_ZK.mp4" \
      "target/$TARGET_COMMON_NAME/patches/wallpapers/mp4/Default_Video_Wallpaper_ZVLB.mp4" \
      "target/$TARGET_COMMON_NAME/patches/wallpapers/mp4/Default_Video_Wallpaper_ZYZO.mp4" \
      "$APKTOOL_DIR/system/priv-app/wallpaper-res/wallpaper-res.apk/res/raw/"
