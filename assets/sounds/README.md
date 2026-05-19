# Custom notification sounds

Place client-provided audio files here, then duplicate to platform locations.

iOS bundle (`.caf` required by APNs):

- `ios/Runner/ringtone.caf`
- `ios/Runner/ping.caf`

Android resources (`.mp3`/`.ogg` allowed, no spaces or uppercase in names):

- `android/app/src/main/res/raw/ringtone.mp3`
- `android/app/src/main/res/raw/ping.mp3`

Convert MP3 to CAF for iOS:

```bash
afconvert ringtone.mp3 ringtone.caf -d ima4 -f caff -v
afconvert ping.mp3     ping.caf     -d ima4 -f caff -v
```
