import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../models/medicine.dart';

class NotificationService {
  static final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  static Timer? _timer;
  static List<Medicine> _medicines = [];

  static Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const ios = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );
    const settings = InitializationSettings(android: android, iOS: ios);
    
    await _notifications.initialize(settings);
    
    const androidChannel = AndroidNotificationChannel(
      'medicine_channel',
      'Medicine Reminders',
      description: 'Notifications for medicine reminders',
      importance: Importance.max,
      playSound: true,
      enableVibration: true,
    );
    
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(androidChannel);
    await androidPlugin?.requestNotificationsPermission();
    await androidPlugin?.requestExactAlarmsPermission();
    
    // Start checking every minute
    _startTimer();
    debugPrint(" Notification service initialized with timer");
  }

  static void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(minutes: 1), (timer) {
      _checkMedicineTime();
    });
  }

  static void _checkMedicineTime() {
    final now = DateTime.now();
    final currentTime = '${now.hour}:${now.minute.toString().padLeft(2, '0')}';
    
    for (final medicine in _medicines) {
      final medicineTime = '${medicine.time.hour}:${medicine.time.minute.toString().padLeft(2, '0')}';
      
      if (currentTime == medicineTime) {
        _showMedicineNotification(medicine);
        debugPrint(" Medicine notification triggered for ${medicine.name} at $currentTime");
      }
    }
  }

  static Future<void> _showMedicineNotification(Medicine medicine) async {
    await _notifications.show(
      medicine.hashCode,
      'Medicine Reminder',
      'Time to take ${medicine.name} - ${medicine.dose}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        ),
      ),
    );
  }

  static Future<void> scheduleMedicineReminder(Medicine medicine, int id) async {
    // Add to our list
    _medicines.add(medicine);
    
    // Show immediate confirmation
    await _notifications.show(
      id,
      'Medicine Added',
      '${medicine.name} reminder set for ${medicine.time.hour}:${medicine.time.minute.toString().padLeft(2, '0')} daily',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        ),
      ),
    );
    
    debugPrint(" Medicine added to timer list: ${medicine.name} at ${medicine.time.hour}:${medicine.time.minute}");
  }

  static Future<void> checkPermissions() async {
    final androidPlugin = _notifications.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final granted = await androidPlugin?.areNotificationsEnabled();
    debugPrint(" Notifications enabled: $granted");
    
    await _notifications.show(
      999999,
      'Permission Test',
      'Notifications are working! Current medicines: ${_medicines.length}',
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'medicine_channel',
          'Medicine Reminders',
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          showWhen: true,
        ),
      ),
    );
  }

  static void updateMedicineList(List<Medicine> medicines) {
    _medicines = medicines;
    debugPrint(" Medicine list updated: ${_medicines.length} medicines");
  }
}