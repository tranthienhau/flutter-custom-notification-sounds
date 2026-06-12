# Screenshot capture flow

Real captures from the iOS Simulator via an integration-test driver (no mockups).

## Steps

1. Boot the simulator (already booted here, UDID `889A2E50-D60F-4785-84BD-5700F9048279`):
   ```bash
   xcrun simctl boot "iPhone 16e"
   open -a Simulator
   ```
2. Scaffold the iOS platform folder (lib-only project) and get dependencies:
   ```bash
   flutter create . --platforms=ios --project-name flutter_custom_notification_sounds
   flutter pub get
   ```
3. Drive the screenshot test:
   ```bash
   flutter drive \
     --driver test_driver/integration_test.dart \
     --target integration_test/screenshot_test.dart \
     -d "889A2E50-D60F-4785-84BD-5700F9048279"
   ```
4. Build the demo GIF from the PNGs:
   ```bash
   cd screenshots
   ffmpeg -y -framerate 1 -pattern_type glob -i '*.png' \
     -vf "scale=320:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" \
     -loop 0 demo.gif
   ```

PNGs + `demo.gif` are written to `screenshots/` and embedded in `README.md`.

## How it works

- `test_driver/integration_test.dart` - `integrationDriver(onScreenshot:)` writes each PNG to `screenshots/<name>.png`.
- `integration_test/screenshot_test.dart` - pumps each screen directly inside a `ProviderScope` (no `main()` Firebase init):
  - `01-login` - pumps `LoginScreen`.
  - `02-chat` - pumps `ChatScreen` with `chatProvider` overridden by a seeded notifier that contains a full support conversation, including a tappable meeting-link bubble (the loud-ringtone notification demo).
  - `03-compose` - enters text into the message composer `TextField`.
  Each step calls `binding.convertFlutterSurfaceToImage()` + `binding.takeScreenshot('NN-name')`.
