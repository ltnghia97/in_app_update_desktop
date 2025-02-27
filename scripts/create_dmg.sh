cd ../
create-dmg \
  "build/macos/Build/Products/Release/in_app_update_desktop.app" \
  "build/macos/" \
  --overwrite \
  --dmg-title="InAppUpdate-Installer" \
  --icon-size 100 \
  --window-pos 200 120 \
  --window-size 600 400 \
  --app-drop-link 400 200

DMG_PATH=$(find build/macos/ -name "*.dmg" | head -n 1)
if [ -f "$DMG_PATH" ]; then
    NEW_DMG_PATH=$(echo "$DMG_PATH" | tr ' ' '_')
    mv "$DMG_PATH" "$NEW_DMG_PATH"
    echo "✅ Đã đổi tên file: $NEW_DMG_PATH"
fi