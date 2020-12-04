import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';import 'package:flutter/services.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';
import 'package:twilio_programmable_voice/events.dart';
import 'package:twilio_programmable_voice/SoundPoolManager.dart';

void main() {
  runApp(MyApp());
}

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  if (message.containsKey('data')) {
    // Handle data message
    final dynamic data = message['data'];
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  FirebaseMessaging firebaseMessaging = FirebaseMessaging();

  Future<void> registerVoice() async {
    // Generate accessToken from backend.
    // http://localhost:3000/accessToken/test
    final tokenResponse =
        await Dio().get("http://host:3000/accessToken/testId");

    print("[TOKEN RESPONSE DATA]");
    print(tokenResponse.data);
    // Get fcmToken.
    final fcmToken = await firebaseMessaging.getToken();
    print("[FCM TOKEN]");
    print(fcmToken);

    TwilioProgrammableVoice.registerVoice(tokenResponse.data, fcmToken);
  }

  @override
  void initState() {
    super.initState();
    print("IN INIT STATE");
    SoundPoolManager.getInstance().playRinging();

    firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        print("onMessage: $message");
        // It's a real push notification
        if (message["notification"]["title"] != null) {}

        // It's a data
        if (message.containsKey("data") && message["data"] != null) {
          // It's a twilio data message
          print("Message contains data");
          if (message["data"].containsKey("twi_message_type")) {
            print("Message is a Twilio Message");

            final dataMap = Map<String, String>.from(message["data"]);

            TwilioProgrammableVoice.handleMessage(dataMap);
            print("handleMessage called in main.dart");
          }
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        print("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        print("onResume: $message");
      },
    );

    initPlatformState();

    TwilioProgrammableVoice.requestMicrophonePermissions().then(print);

    TwilioProgrammableVoice.addCallStatusListener(print);

    // To test event
    // Map<String, String> fakeData = {"foo": "bar"};
    // TwilioProgrammableVoice.handleMessage(fakeData);

    TwilioProgrammableVoice.callStatusStream.listen((event) async {
      print("RECEIVED EVENT :");

      switch (event.runtimeType) {
        case CallInvite:
          print("CALL_INVITE: ");
          print(event.to);
          print(event.from);
          print(event.callSid);
          // SoundPoolManager.getInstance().playRinging();
          await Future.delayed(Duration(seconds: 3));
          final callResponse = await TwilioProgrammableVoice.answer();
          print(callResponse);
          break;

        case CancelledCallInvite:
          print("CANCELLED_CALL_INVITE: ");
          print(event.to);
          print(event.from);
          print(event.callSid);
          break;

        case CallConnectFailure:
          print("CALL_CONNECT_FAILURE: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallRinging:
          print("CALL_RINGING: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallConnected:
          print("CALL_CONNECTED: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallReconnecting:
          print("CALL_RECONNECTING: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallReconnected:
          print("CALL_RECONNECTED: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallDisconnected:
          print("CALL_DISCONNECTED: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        case CallQualityWarningChanged:
          print("CALL_QUALITY_WARNING_CHANGED: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          break;

        default:
          break;
      }
    });

    this.registerVoice();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await TwilioProgrammableVoice.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
