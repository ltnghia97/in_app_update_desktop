flutter clean
flutter pub get
flutter build macos --release

./create_dmg.sh
./mv_file.sh