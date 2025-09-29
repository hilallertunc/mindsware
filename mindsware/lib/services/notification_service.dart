
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  NotificationService._internal();
  static final NotificationService _i = NotificationService._internal();
  factory NotificationService() => _i;


  static final navigatorKey = GlobalKey<NavigatorState>();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _channelId = 'mindsware_channel';
  static const String _channelName = 'MindsWare Alerts';
  static const String _channelDesc = 'MindsWare yerel hatırlatmalar';

  Future<void> init({String timezoneName = 'Europe/Istanbul'}) async {

    tz.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation(timezoneName));

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings =
        InitializationSettings(android: androidInit, iOS: iosInit);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        final payload = details.payload ?? '';
      
        if (payload == 'open_places') {
          navigatorKey.currentState?.pushNamed('/placeSuggestion');
        } else if (payload == 'open_analysis') {
          navigatorKey.currentState?.pushNamed('/analysis');
        } else {
          navigatorKey.currentState?.pushNamed('/analysis');
        }
      },
      onDidReceiveBackgroundNotificationResponse: _notificationTapBackground,
    );

  
    if (Platform.isAndroid) {
      await _plugin
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.requestNotificationsPermission();
    }

  
    const channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDesc,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }


  Future<void> showNow({
    required String title,
    required String body,
    String? payload,
    int id = 1000,
  }) async {
    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );
    await _plugin.show(id, title, body, details, payload: payload);
  }


  Future<void> scheduleOneOff({
    required Duration after,
    required String title,
    required String body,
    String? payload,
    int id = 2000,
    bool exact = false,
  }) async {
    final when = tz.TZDateTime.now(tz.local).add(after);

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: exact
          ? AndroidScheduleMode.exactAllowWhileIdle
          : AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: null,
      payload: payload,
    );
  }


  Future<void> scheduleDailyAt({
    required int hour,
    required int minute,
    String title = 'Gün sonu farkındalık',
    String body = 'Bugünü kısa bir değerlendirme ile kapatmaya ne dersin?',
    String? payload,
    int id = 3000,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);
    if (when.isBefore(now)) when = when.add(const Duration(days: 1));

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: payload,
    );
  }


  Future<void> scheduleWeeklyAt({
    required int weekday, 
    required int hour,
    required int minute,
    required String title,
    required String body,
    String? payload,
    int id = 4000,
  }) async {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour, minute);

    while (when.weekday != weekday || when.isBefore(now)) {
      when = when.add(const Duration(days: 1));
    }

    final details = NotificationDetails(
      android: const AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDesc,
        importance: Importance.high,
        priority: Priority.high,
        icon: '@mipmap/ic_launcher',
      ),
      iOS: const DarwinNotificationDetails(),
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      when,
      details,
      androidScheduleMode: AndroidScheduleMode.alarmClock,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: payload,
    );
  }

 
  Future<void> cancel(int id) => _plugin.cancel(id);
  Future<void> cancelAll() => _plugin.cancelAll();
}

@pragma('vm:entry-point')
void _notificationTapBackground(NotificationResponse details) {
  
}
