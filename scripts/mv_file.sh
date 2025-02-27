SOURCE_DIR="../build/macos/"
DEST_DIR="../app_version_check/installers/macos/"
VERSION_FILE="../app_version_check/version.json"

DMG_PATH=$(find "$SOURCE_DIR" -name "*.dmg" | head -n 1)
if [ -z "$DMG_PATH" ]; then
    echo "❌ Không tìm thấy file .dmg trong $SOURCE_DIR"
    exit 1
fi

DMG_NAME=$(basename "$DMG_PATH" | tr ' ' '_')
mv "$DMG_PATH" "$DEST_DIR$DMG_NAME"
#echo "✅ Đã di chuyển file: $DMG_NAME vào $DEST_DIR"

# Copy tên file vào clipboard (macOS dùng pbcopy)
echo -n "$DMG_NAME" | pbcopy

echo "📋 Đã copy tên file vào clipboard: $DMG_NAME"

# Cập nhật version.json với tên file mới
if command -v jq &> /dev/null; then
    jq --arg filename "$DMG_NAME" '.macos_file_name = "installers/macos/" + $filename' "$VERSION_FILE" > temp.json && mv temp.json "$VERSION_FILE"
    echo "✅ Đã cập nhật version.json với tên file: $DMG_NAME"
else
    echo "❌ Lỗi: jq chưa được cài đặt. Hãy cài đặt bằng: brew install jq"
    exit 1
fi

## Kiểm tra xem có thay đổi nào không
#if [ -z "$(git status --porcelain)" ]; then
#    echo "✅ Không có thay đổi nào để commit."
#    exit 0
#fi
#
## Thêm tất cả các file đã thay đổi vào git
#git add .
#
## Tạo thông điệp commit tự động với timestamp
#COMMIT_MESSAGE="Auto commit: $(date +"%Y-%m-%d %H:%M:%S")"
#git commit -m "$COMMIT_MESSAGE"
#
## Push lên remote (branch hiện tại)
#git push origin "$(git rev-parse --abbrev-ref HEAD)"
#
#echo "🚀 Đã commit và push thành công!"
