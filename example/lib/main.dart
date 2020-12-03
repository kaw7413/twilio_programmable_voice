import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';
// @TODO: export * from ... to avoid multiple import statements
import 'package:twilio_programmable_voice/models/events.dart';
import 'package:uuid/uuid.dart';

const callKeepSetupConfig = <String, dynamic>{
  'ios': {
    'appName': 'Bilik Pro',
  },
  'android': {
    'alertTitle': 'Permission requise',
    'alertDescription':
    'Bilik Pro a besoin d\'accèder aux appels',
    'cancelButton': 'Fermer Bilik Pro',
    'okButton': 'Autoriser',
  },
};

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

/// For fcm background message handler.
final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;
Map<String, String> currentCallInviteDate = new Map();

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // It's a data
  if (message.containsKey("data") && message["data"] != null) {
    // It's a twilio data message
    print("Message contains data");
    if (message["data"].containsKey("twi_message_type")) {
      print("Message is a Twilio Message");

      final dataMap = Map<String, String>.from(message["data"]);
      currentCallInviteDate = dataMap;

      final callUUID = Uuid().v4();

      _callKeep.on(CallKeepPerformAnswerCallAction(),
              (CallKeepPerformAnswerCallAction event) {
            print(
                'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');
            _callKeep.startCall(event.callUUID, "number", "number");

            Timer(const Duration(seconds: 1), () {
              print('[setCurrentCallActive] $callUUID, number: "number"');
              _callKeep.setCurrentCallActive(callUUID);
            });
            //_callKeep.endCall(event.callUUID);
          });

      _callKeep.on(CallKeepPerformEndCallAction(),
              (CallKeepPerformEndCallAction event) {
            print('backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');
          });

      if (!_callKeepInited) {
        _callKeep.setup(callKeepSetupConfig);
        _callKeepInited = true;
      }

      _callKeep.displayIncomingCall(callUUID, "number");
      _callKeep.backToForeground();

      // TODO: Make sure the accessToken is still valid ?
      // We can't handle message here, need to create the call screen first
      // TwilioProgrammableVoice.handleMessage(dataMap);
      print("handleMessage called in main.dart");
    }
  }

  if (message.containsKey('notification')) {
    // Handle notification message
    final dynamic notification = message['notification'];
  }

  // Or do other work.
}

class Call {
  Call(this.number);
  String number;
  bool held = false;
  bool muted = false;
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _platformVersion = 'Unknown';
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterCallkeep _callKeep = FlutterCallkeep();
  Map<String, Call> calls = {};
  String newUUID() => Uuid().v4();

  Future<void> registerVoice() async {
    // Generate accessToken from backend.
    // http://localhost:3000/accessToken/test
    final tokenResponse =
    await Dio().get("http://host:3000/accessToken/defaultId");

    print("[TOKEN RESPONSE DATA]");
    print(tokenResponse.data);
    // Get fcmToken.
    final fcmToken = await _firebaseMessaging.getToken();
    print("[FCM TOKEN]");
    print(fcmToken);

    TwilioProgrammableVoice.registerVoice(tokenResponse.data, fcmToken);
  }

  void iOS_Permission() {
    _firebaseMessaging.requestNotificationPermissions(
        IosNotificationSettings());
    _firebaseMessaging.onIosSettingsRegistered
        .listen((IosNotificationSettings settings) {
      print('Settings registered: $settings');
    });
  }

  Future<void> initCallKeep() async {
    _callKeep.on(CallKeepDidDisplayIncomingCall(), didDisplayIncomingCall);
    _callKeep.on(CallKeepPerformAnswerCallAction(), answerCall);
    _callKeep.on(CallKeepDidPerformDTMFAction(), didPerformDTMFAction);
    _callKeep.on(
        CallKeepDidReceiveStartCallAction(), didReceiveStartCallAction);
    _callKeep.on(CallKeepDidToggleHoldAction(), didToggleHoldCallAction);
    _callKeep.on(
        CallKeepDidPerformSetMutedCallAction(), didPerformSetMutedCallAction);
    _callKeep.on(CallKeepPerformEndCallAction(), endCall);
    _callKeep.on(CallKeepPushKitToken(), onPushKitToken);

    _callKeep.setup(callKeepSetupConfig);
  }

  @override
  void initState() {
    super.initState();

    initCallKeep();

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

    initPlatformState();

    TwilioProgrammableVoice.requestMicrophonePermissions().then(print);

    TwilioProgrammableVoice.addCallStatusListener(print);

    /*
    // To test event
    Map<String, String> fakeData = {"foo": "bar"};
    TwilioProgrammableVoice.handleMessage(fakeData);
    */
    TwilioProgrammableVoice.callStatusStream.listen((event) async {
      print("RECEIVED EVENT :");

      // @TODO: event is [CLASS]
      switch (event.runtimeType) {
        case CallInvite:
          print("CALL_INVITE: ");
          print(event.to);
          print(event.from);
          print(event.callSid);
          await displayIncomingCall(event.from);
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

  void removeCall(String callUUID) {
    setState(() {
      calls.remove(callUUID);
    });
  }

  void setCallHeld(String callUUID, bool held) {
    setState(() {
      calls[callUUID].held = held;
    });
  }

  void setCallMuted(String callUUID, bool muted) {
    setState(() {
      calls[callUUID].muted = muted;
    });
  }

  Future<void> answerCall(CallKeepPerformAnswerCallAction event) async {
    final String callUUID = event.callUUID;
    final String number = calls[callUUID].number;
    print('[answerCall] $callUUID, number: $number');

    TwilioProgrammableVoice.answer();

    _callKeep.startCall(event.callUUID, number, number);
    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: $number');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> endCall(CallKeepPerformEndCallAction event) async {
    print('endCall: ${event.callUUID}');
    removeCall(event.callUUID);
  }

  Future<void> didPerformDTMFAction(CallKeepDidPerformDTMFAction event) async {
    print('[didPerformDTMFAction] ${event.callUUID}, digits: ${event.digits}');
  }

  Future<void> didReceiveStartCallAction(
      CallKeepDidReceiveStartCallAction event) async {
    if (event.handle == null) {
      // @TODO: sometime we receive `didReceiveStartCallAction` with handle` undefined`
      return;
    }
    final String callUUID = event.callUUID ?? newUUID();
    setState(() {
      calls[callUUID] = Call(event.handle);
    });
    print('[didReceiveStartCallAction] $callUUID, number: ${event.handle}');

    _callKeep.startCall(callUUID, event.handle, event.handle);

    Timer(const Duration(seconds: 1), () {
      print('[setCurrentCallActive] $callUUID, number: ${event.handle}');
      _callKeep.setCurrentCallActive(callUUID);
    });
  }

  Future<void> didPerformSetMutedCallAction(
      CallKeepDidPerformSetMutedCallAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[didPerformSetMutedCallAction] ${event.callUUID}, number: $number (${event.muted})');

    setCallMuted(event.callUUID, event.muted);
  }

  Future<void> didToggleHoldCallAction(
      CallKeepDidToggleHoldAction event) async {
    final String number = calls[event.callUUID].number;
    print(
        '[didToggleHoldCallAction] ${event.callUUID}, number: $number (${event.hold})');

    setCallHeld(event.callUUID, event.hold);
  }

  Future<void> hangup(String callUUID) async {
    _callKeep.endCall(callUUID);
    removeCall(callUUID);
  }

  Future<void> setOnHold(String callUUID, bool held) async {
    _callKeep.setOnHold(callUUID, held);
    final String handle = calls[callUUID].number;
    print('[setOnHold: $held] $callUUID, number: $handle');
    setCallHeld(callUUID, held);
  }

  Future<void> setMutedCall(String callUUID, bool muted) async {
    _callKeep.setMutedCall(callUUID, muted);
    final String handle = calls[callUUID].number;
    print('[setMutedCall: $muted] $callUUID, number: $handle');
    setCallMuted(callUUID, muted);
  }

  Future<void> updateDisplay(String callUUID) async {
    final String number = calls[callUUID].number;
    // Workaround because Android doesn't display well displayName, se we have to switch ...
    if (isIOS) {
      _callKeep.updateDisplay(callUUID,
          displayName: 'New Name', handle: number);
    } else {
      _callKeep.updateDisplay(callUUID,
          displayName: number, handle: 'New Name');
    }

    print('[updateDisplay: $number] $callUUID');
  }

  Future<void> displayIncomingCallDelayed(String number) async {
    Timer(const Duration(seconds: 3), () {
      displayIncomingCall(number);
    });
  }

  Future<void> displayIncomingCall(String number) async {
    final String callUUID = newUUID();
    setState(() {
      calls[callUUID] = Call(number);
    });
    print('Display incoming call now');
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
        handleType: 'number', hasVideo: false);
  }

  void didDisplayIncomingCall(CallKeepDidDisplayIncomingCall event) {
    var callUUID = event.callUUID;
    var number = event.handle;
    print('[displayIncomingCall] $callUUID number: $number');
    setState(() {
      calls[callUUID] = Call(number);
    });
  }

  void onPushKitToken(CallKeepPushKitToken event) {
    print('[onPushKitToken] token => ${event.token}');
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