import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import '../../components/injection/injection_container.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:na0826/core/usecases/usecase.dart';
import '../../models/message_notify_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../main.dart';
import 'dart:convert';
import 'dart:async';
import 'dart:io';




class FirebaseNotifications {

  static final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static late BuildContext context;

  static Future<void> setUpFirebase() async {

    final settings = await _firebaseMessaging.requestPermission(
      criticalAlert: false,
      announcement: false,
      provisional: false,
      carPlay: false,
      badge: true,
      alert: true,
      sound: true,
    );

    await _firebaseMessaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    logger.i('User granted permission: ${settings.authorizationStatus}');
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      logger.i('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      logger.i('User granted provisional permission');
    } else {
      logger.i('User declined or has not accepted permission');
    }
    // firebaseCloudMessagingListeners();
  }

  static Future<String?> getToken() async {
    return await _firebaseMessaging.getToken();
  }

  static Future<void> deleteToken() async {
    return await _firebaseMessaging.deleteToken();
  }

  static void messagingListeners({required BuildContext cnx}) {
    try {

      context = cnx;
      FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
        logger.i('onMessage: ${message.data}');
        if (Platform.isAndroid) {
        // if (message.data.isNotEmpty && Platform.isAndroid) {
          _createNotification(message);
        }
      });

      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) async {
        if(message.data.isNotEmpty) {
          var data = json.encode(message.data);
          MessageNotifyModel msg = messageNotifyModelFromJson(data);
          await redirect(msg);
        } else {
          NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin
              .getNotificationAppLaunchDetails();
          if (details != null && details.didNotificationLaunchApp && details.payload != null) {
            var data = json.encode(details.payload);
            MessageNotifyModel msg = messageNotifyModelFromJson(data);
            await redirect(msg);
          }
        }
      });

      FirebaseMessaging.instance.getInitialMessage().then((RemoteMessage? message) async {
        if(message != null && message.data.isNotEmpty) {
          var data = json.encode(message.data);
          MessageNotifyModel msg = messageNotifyModelFromJson(data);
          await redirect(msg);
        } else {
          NotificationAppLaunchDetails? details = await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
          if (details != null && details.didNotificationLaunchApp && details.payload != null) {
            MessageNotifyModel msg = messageNotifyModelFromJson(details.payload!);
            await redirect(msg);
          }
        }
      });
    } catch(e) {
      logger.e(e);
    }
  }

  static void _createNotification(RemoteMessage message) async {
    RemoteNotification? notification = message.notification;
    AndroidNotification? android = message.notification?.android;
    // var data = json.encode(message.data);
    // MessageNotifyModel msg = messageNotifyModelFromJson(data);
    await flutterLocalNotificationsPlugin.show(
      message.hashCode,
      notification?.title??'',
      notification?.body??'',
      NotificationDetails(
        android: AndroidNotificationDetails(
          channel.id,
          channel.name,
          priority: Priority.high,
          importance: Importance.max,
          icon: android?.smallIcon,
          playSound: true,
          sound: const RawResourceAndroidNotificationSound('positive'),
          color: const Color(0xFF00A4DC),
        ),
        iOS: const IOSNotificationDetails(),
      ),
      // payload: data,
    );
  }


  static Future selectNotification(String? payload) async {
    if (payload != null) {
      MessageNotifyModel msg = messageNotifyModelFromJson(payload);
      await redirect(msg);
    }
  }

  static Future<void> redirect(MessageNotifyModel msg) async {
    try {
      if (msg.action == describeEnum(actionNotification.notification)) {

      }
    } catch(e) {
      logger.e(e);
    }
  }

}
