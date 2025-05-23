echo "Improve WiFi/Mobile Data speeds"

DELETE_FROM_WORK_DIR "product" "overlay/ConnectivityUxOverlay"
DELETE_FROM_WORK_DIR "product" "overlay/NetworkStackOverlay"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "overlay/ConnectivityUxOverlay" 0 0 755 "u:object_r:system_file:s0"
ADD_TO_WORK_DIR "$TARGET_FIRMWARE" "product" "overlay/NetworkStackOverlay" 0 0 755 "u:object_r:system_file:s0"
