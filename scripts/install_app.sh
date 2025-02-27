# Kiểm tra xem có truyền file .dmg vào không
if [ -z "$1" ]; then
    echo "⚠️  Vui lòng truyền vào tên file .dmg!"
    echo "👉 Cách dùng: ./install_app.sh ten_file.dmg"
    exit 1
fi

# Lấy đường dẫn file .dmg từ thư mục Downloads
DMG_FILE=~/Downloads/"$1"

# Kiểm tra nếu không tìm thấy file .dmg
if [ -z "$DMG_FILE" ]; then
    echo "❌ Không tìm thấy file .dmg trong thư mục Downloads!"
    exit 1
fi

# Mount file .dmg và lấy tên thư mục mount
MOUNT_DIR=$(hdiutil attach "$DMG_FILE" | grep Volumes | awk -F'\t' '{print $NF}')

# Kiểm tra nếu mount không thành công
if [ -z "$MOUNT_DIR" ]; then
    echo "❌ Không thể mount file .dmg!"
    exit 1
fi

echo "✅ Mounted vào: $MOUNT_DIR"

# Tìm ứng dụng .app trong DMG (hỗ trợ cả khi nằm trong thư mục con)
APP_PATH=$(find "$MOUNT_DIR" -name "*.app" -maxdepth 2 | head -n 1)

if [ -z "$APP_PATH" ]; then
    echo "❌ Không tìm thấy file .app trong $MOUNT_DIR!"
    hdiutil detach "$MOUNT_DIR"
    exit 1
fi

APP_NAME=$(basename "$APP_PATH")

echo "📂 Mở cửa sổ Finder hiển thị file .app..."
open "$MOUNT_DIR"

sleep 2  # Chờ Finder mở lên

echo "📦 Đang kéo ứng dụng vào thư mục Applications..."

# Tự động kéo ứng dụng vào /Applications bằng Finder
osascript <<EOF
tell application "Finder"
    set dmgApp to POSIX file "$APP_PATH" as alias
    set applicationsFolder to POSIX file "/Applications" as alias
    duplicate dmgApp to applicationsFolder with replacing
end tell
EOF

echo "✅ Ứng dụng đã được cài đặt thành công!"

# Đóng cửa sổ Finder hiển thị file .dmg
echo "❌ Đóng cửa sổ Finder..."
osascript <<EOF
tell application "Finder"
    close windows
end tell
EOF

# Chạy ứng dụng sau khi cài đặt
echo "🚀 Đang mở ứng dụng: $APP_NAME"
open "/Applications/$APP_NAME"

# Unmount DMG
hdiutil detach "$MOUNT_DIR"

## Xóa file .dmg sau khi cài đặt
#rm "$DMG_FILE"

echo "🎉 Đã cài đặt thành công $APP_NAME vào /Applications!"