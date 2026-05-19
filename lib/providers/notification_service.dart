import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

const meetingChannelId = 'meeting_channel';
const meetingChannelName = 'Incoming meetings';
const messageChannelId = 'message_channel';
const messageChannelName = 'Chat messages';

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  final _local = FlutterLocalNotificationsPlugin();
  final _meetingUrlController = StreamController<String>.broadcast();
  Stream<String> get meetingUrlStream => _meetingUrlController.stream;

  Future<void> init() async {
    const initSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      iOS: DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: true,
      ),
    );
    await _local.initialize(initSettings, onDidReceiveNotificationResponse: _onTap);

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          meetingChannelId,
          meetingChannelName,
          description: 'Incoming meeting alerts with loud ringtone',
          importance: Importance.high,
          sound: RawResourceAndroidNotificationSound('ringtone'),
          enableVibration: true,
          playSound: true,
        ));

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(const AndroidNotificationChannel(
          messageChannelId,
          messageChannelName,
          description: 'Standard chat message notifications',
          importance: Importance.defaultImportance,
          sound: RawResourceAndroidNotificationSound('ping'),
          playSound: true,
        ));

    try {
      final fcm = FirebaseMessaging.instance;
      await fcm.requestPermission(alert: true, badge: true, sound: true);
      FirebaseMessaging.onMessage.listen(_handleRemote);
      FirebaseMessaging.onMessageOpenedApp.listen(_handleOpened);
    } catch (e) {
      if (kDebugMode) debugPrint('FCM unavailable: $e');
    }
  }

  Future<void> _handleRemote(RemoteMessage msg) async {
    final type = msg.data['type'] ?? 'message';
    if (type == 'meeting') {
      await _local.show(
        msg.hashCode,
        msg.notification?.title ?? 'Incoming meeting',
        msg.notification?.body ?? 'Support is calling',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            meetingChannelId,
            meetingChannelName,
            importance: Importance.high,
            priority: Priority.high,
            fullScreenIntent: true,
            category: AndroidNotificationCategory.call,
            sound: RawResourceAndroidNotificationSound('ringtone'),
          ),
          iOS: DarwinNotificationDetails(
            sound: 'ringtone.caf',
            presentSound: true,
            interruptionLevel: InterruptionLevel.timeSensitive,
          ),
        ),
        payload: msg.data['meeting_url'],
      );
    } else {
      await _local.show(
        msg.hashCode,
        msg.notification?.title ?? 'Support',
        msg.notification?.body ?? '',
        const NotificationDetails(
          android: AndroidNotificationDetails(
            messageChannelId,
            messageChannelName,
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
            sound: RawResourceAndroidNotificationSound('ping'),
          ),
          iOS: DarwinNotificationDetails(sound: 'ping.caf'),
        ),
      );
    }
  }

  void _handleOpened(RemoteMessage msg) {
    final url = msg.data['meeting_url'];
    if (url != null) _meetingUrlController.add(url);
  }

  void _onTap(NotificationResponse r) {
    final url = r.payload;
    if (url != null) _meetingUrlController.add(url);
  }
}
