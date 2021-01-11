import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'callkeep_functions.dart';
import 'background_message_handler.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterCallkeep _callKeep = FlutterCallkeep();

  Future<void> registerVoice() async {
    // Generate accessToken from backend.
    // http://localhost:3000/accessToken/test
    final tokenResponse = await Dio().get("http://host:3000/accessToken/testId"); // TODO testId should be a varaible

    print("[TOKEN RESPONSE DATA]");
    print(tokenResponse.data);
    // Get fcmToken.
    final fcmToken = await _firebaseMessaging.getToken();
    print("[FCM TOKEN]");
    print(fcmToken);

    TwilioProgrammableVoice.registerVoice(tokenResponse.data, fcmToken);
  }

  Future<void> makeCall(String number) async {
    print('[makeCall]');

    final String callUUID = TwilioProgrammableVoice.getCall.sid;
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();

    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
        'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }

    print('[makeCall] $callUUID number: $number');

    _callKeep.startCall(callUUID, number, "callerName");
  }

  Future<void> displayIncomingCall(String number) async {
    print('Display incoming call now');

    final String callUUID = TwilioProgrammableVoice.getCall.sid;
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();

    if (!hasPhoneAccount) {
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
        'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }

    print('[displayIncomingCall] $callUUID number: $number');

    _callKeep.displayIncomingCall(callUUID, number,
        handleType: 'number', hasVideo: false, localizedCallerName: "callerName");
  }

  @override
  void initState() {
    super.initState();
    initCallKeep(_callKeep);

    _firebaseMessaging.configure(
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

    TwilioProgrammableVoice.requestMicrophonePermissions().then(print);
    TwilioProgrammableVoice.addCallStatusListener(print);
    TwilioProgrammableVoice.callStatusStream.listen((event) async {
      print("RECEIVED EVENT :");
      switch (event.runtimeType) {
        case CallInvite:
          print("CALL_INVITE: ");
          print(event.to);
          print(event.from);
          print(event.sid);
          SoundPoolManager.getInstance().playIncoming();
          await displayIncomingCall(event.from);
          await Future.delayed(Duration(seconds: 3));
          final callResponse = await TwilioProgrammableVoice.answer();
          print(callResponse);
          break;

        case CancelledCallInvite:
          print("CANCELLED_CALL_INVITE: ");
          print(event.to);
          print(event.from);
          print(event.sid);
          SoundPoolManager.getInstance().stopRinging();
          SoundPoolManager.getInstance().playDisconnect();
          break;

        case CallConnectFailure:
          print("CALL_CONNECT_FAILURE: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          SoundPoolManager.getInstance().stopRinging();
          break;

        case CallRinging:
          print("CALL_RINGING: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          // TwilioProgrammableVoice.getCall.to and TwilioProgrammableVoice.getCall.from are always null when making a call
          // TODO replace brut phone number with TwilioProgrammableVoice.getCall.to
          await makeCall("+33787934070");
          if (event.from == "+33644645795") {
            SoundPoolManager.getInstance().playOutgoing();
          }
          break;

        case CallConnected:
          print("CALL_CONNECTED: ");
          print(event.to);
          print(event.from);
          print(event.state);
          print(event.sid);
          print(event.isMuted.toString());
          print(event.isOnHold.toString());
          SoundPoolManager.getInstance().stopRinging();
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
          // Maybe we need to ensure their is no ringing with SoundPoolManager.getInstance().stopRinging();
          SoundPoolManager.getInstance().playDisconnect();

          // @TODO: only end the current active call
          _callKeep.endAllCalls();
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

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: AppBar(
            title: const Text('Plugin example app'),
          ),
          body: Column(
            children: [
              FlatButton(
                  onPressed: () {
                    TwilioProgrammableVoice.makeCall(
                        from: "+33644645795", to: "+33787934070");
                  },
                  child: Text('Call'))
            ],
          )),
    );
  }
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Welcome to Flutter',
      debugShowCheckedModeBanner: false,
      home: MyHomePage(),
    );
  }
}
