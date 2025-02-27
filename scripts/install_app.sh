#!/bin/bash

# Định nghĩa thư mục Downloads
DOWNLOAD_DIR="$HOME/Downloads"

# Tìm file .dmg mới nhất có tên bắt đầu với "in_app_update_desktop"
DMG_FILE=$(ls -t "$DOWNLOAD_DIR" | grep -E "in_app_update_desktop_1.0.1.dmg" | head -n 1)

# Kiểm tra nếu không tìm thấy file
if [ -z "$DMG_FILE" ]; then
    echo "❌ Không tìm thấy file .dmg trong $DOWNLOAD_DIR"
    exit 1
fi

# Đường dẫn đầy đủ tới file
DMG_PATH="$DOWNLOAD_DIR/$DMG_FILE"

echo "📂 Tìm thấy file DMG: $DMG_PATH"

# Mở file .dmg
echo "🚀 Đang mở $DMG_PATH..."
open "$DMG_PATH"
