import 'dart:io';
import 'dart:convert';

import 'package:canli_sohbet_app/app/chat_page.dart';
import 'package:canli_sohbet_app/view-models/chat_view_model.dart';
import 'package:canli_sohbet_app/view-models/user_view_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';


FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

Future<void> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
    print("Arka planda gelen data: " + message["data"].toString());
    NotificationHandler.showNotification(message);
  }
   //Notification kullanmıyoruz.
  /*if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }*/

  // Or do other work.
  return Future<void>.value();
}

class NotificationHandler{

  FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  static final NotificationHandler _singleton = NotificationHandler._internal();
  BuildContext myContext;

  factory NotificationHandler(){
    return _singleton;
  }

  NotificationHandler._internal();

  initializeFCMNotification(BuildContext context) async{
    myContext = context;

    AndroidInitializationSettings initializationSettingsAndroid = AndroidInitializationSettings('app_icon');
    IOSInitializationSettings initializationSettingsIOS =
    IOSInitializationSettings(
        onDidReceiveLocalNotification: onDidReceiveLocalNotification );

    InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,onSelectNotification: onSelectNotification);


   /* _firebaseMessaging.subscribeToTopic("sport");

    String token = await _firebaseMessaging.getToken();
    print("Token: $token");*/

    _firebaseMessaging.onTokenRefresh.listen((newToken) async{
      User _currentUser = FirebaseAuth.instance.currentUser;
      await FirebaseFirestore.instance.doc("tokens/${_currentUser.uid}").set({
        "token" : newToken
      });
    });

    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        showNotification(message);
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );
  }

  Future onDidReceiveLocalNotification(int id, String title, String body, String payload) {
  }

  static _downloadAndSaveMessage(String url, String name) async{
    Directory directory = await getApplicationDocumentsDirectory();
    var filePath = '${directory.path}/$name';
    var response = await http.get(url);
    File file = File(filePath);
    await file.writeAsBytes(response.bodyBytes);
    return filePath;
  }

  static void showNotification(Map<String, dynamic> message) async{
    var userURLPath = await _downloadAndSaveMessage(message["data"]["profileURL"], 'largeIcon');

    var  person = Person(
      name: message["data"]["title"],
      key: "1",
      icon: BitmapFilePathAndroidIcon(userURLPath),
    );

    var messageStyle = MessagingStyleInformation(person, messages: [Message(message["data"]["message"], DateTime.now(), person)]);

    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        '1234', 'Yeni Mesaj', 'your channel description',
        category: "msg",
        styleInformation: messageStyle,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker');
    var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics
    );
    await flutterLocalNotificationsPlugin.show(
        0, message["data"]["title"],
        message["data"]["message"], platformChannelSpecifics,
        payload: jsonEncode(message));
  }

  Future onSelectNotification(String payload) async{
    final _userViewModel = Provider.of<UserViewModel>(myContext, listen: false);
    if(payload != null){
      debugPrint("Notification Payload : " + payload);

      Map<String, dynamic> receiveNotification = await jsonDecode(payload);

      var typedUser = await _userViewModel.getUser(receiveNotification["data"]["senderUserID"]);
      Navigator.of(myContext, rootNavigator: true).push(
        MaterialPageRoute(builder: (context) => ChangeNotifierProvider(
            create: (context) => ChatViewModel(currentUser: _userViewModel.userModel, typedUser: typedUser),
            child: ChatPage()
        ),),
      );
    }
  }
}
