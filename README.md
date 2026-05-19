# flutter-custom-notification-sounds

Lightweight Flutter support-chat app demonstrating **two distinct custom push
notification sounds** on iOS + Android:

1. **Incoming meeting alert** - loud ringtone, plays up to 30s like a real call.
   Triggered by a `type=meeting` data payload. Tap opens a video meeting URL in
   the system browser.
2. **New message / info** - short soft chat ping. Triggered by
   `type=message` payloads.

The backend chooses which sound to trigger per notification.

## Stack

- Flutter + Dart
- Riverpod
- Firebase Cloud Messaging (FCM) - cross-platform delivery
- `flutter_local_notifications` - Android channels w/ per-channel custom sound
- iOS: APNs payload with `aps.sound = "ringtone.caf"` / `"ping.caf"` (custom sounds bundled in app)
- url_launcher - open meeting URL in browser

## Sound files

Place provided MP3s (converted to platform formats) here:

- iOS: `ios/Runner/ringtone.caf`, `ios/Runner/ping.caf` (must be in main bundle)
- Android: `android/app/src/main/res/raw/ringtone.mp3`, `android/app/src/main/res/raw/ping.mp3`

iOS sounds must be `.caf`, `.aiff`, or `.wav` (no MP3 for APNs). Convert with:

```bash
afconvert ringtone.mp3 ringtone.caf -d ima4 -f caff -v
```

## Backend payload

**Meeting (loud ringtone, 30s repeat):**

```json
{
  "to": "<fcm_token>",
  "notification": {
    "title": "Incoming meeting",
    "body": "Support is calling",
    "sound": "ringtone"
  },
  "apns": {
    "payload": {
      "aps": {
        "sound": "ringtone.caf",
        "content-available": 1,
        "interruption-level": "time-sensitive"
      }
    }
  },
  "data": {
    "type": "meeting",
    "meeting_url": "https://meet.example.com/abc"
  }
}
```

**Message (soft ping):**

```json
{
  "to": "<fcm_token>",
  "notification": {
    "title": "Support",
    "body": "Payment received",
    "sound": "ping"
  },
  "apns": {
    "payload": { "aps": { "sound": "ping.caf" } }
  },
  "data": { "type": "message" }
}
```

## Android channels

Two channels are created at boot:

- `meeting_channel` - importance HIGH, sound = `ringtone.mp3`, vibration repeats
- `message_channel` - importance DEFAULT, sound = `ping.mp3`

The channel sound is set at create-time and cannot change later, so per-message
sound selection happens by routing the message to the correct channel.

## Run

```bash
flutter pub get
flutter run
```

Wire your backend to call FCM HTTP v1 / APNs with the payloads above.
