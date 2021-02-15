import 'dart:async';
import 'dart:io' show Platform;

import 'package:callkeep/callkeep.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

import 'background_message_handler.dart';
import 'callkeep_functions.dart';

final logger = Logger();

void main() async {
  Logger.level = Level.debug;

  await DotEnv().load('.env');

  runApp(TwilioProgrammingVoiceExampleApp());
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final TwilioProgrammableVoice _twilioProgrammableVoice = TwilioProgrammableVoice();
  final FlutterCallkeep _callKeep = FlutterCallkeep();

  Future<void> setUpTwilioProgrammableVoice() async {
    await TwilioProgrammableVoice().requestMicrophonePermissions().then(logger.d);
    await checkDefaultPhoneAccount();
    // TODO uncomment this when callkeep merge our pull request
    // await checkDefaultPhoneAccount().then((userAccept) {
    //   // we can use this callback to handle the case where the end user refuse to give the telecom manager permission
    //   logger.d("User has taped ok the telecom manager permission dialog : " + userAccept.toString());
    // });

    TwilioProgrammableVoice().callStatusStream.listen((event) async {
      logger.d("[TwilioProgrammableVoice() Event]");

      // TODO: make this readable
      if (event is CallInvite) {
        logger.d("CALL_INVITE", event);
        SoundPoolManager.getInstance().playIncoming();
        await displayIncomingCallInvite(event.from, "CallerDisplayName");
      } else if (event is CancelledCallInvite) {
        logger.d("CANCELLED_CALL_INVITE", event);
        SoundPoolManager.getInstance().stopRinging();
        SoundPoolManager.getInstance().playDisconnect();
      } else if (event is CallConnectFailure) {
        logger.d("CALL_CONNECT_FAILURE", event);
        SoundPoolManager.getInstance().stopRinging();
      } else if (event is CallRinging) {
        logger.d("CALL_RINGING", event);
        SoundPoolManager.getInstance().stopRinging();
        // TwilioProgrammableVoice().getCall.to and TwilioProgrammableVoice().getCall.from are always null when making a call
        // TODO replace brut phone number with TwilioProgrammableVoice().getCall.to
        await displayMakeCallScreen("+33787934070", "Display Caller Name");
      } else if (event is CallConnected) {
        logger.d("CALL_CONNECTED", event);
        SoundPoolManager.getInstance().stopRinging();
      } else if (event is CallReconnecting) {
        logger.d("CALL_RECONNECTING", event);
      } else if (event is CallReconnected) {
        logger.d("CALL_RECONNECTED", event);
      } else if (event is CallDisconnected) {
        logger.d("CALL_DISCONNECTED", event);
        // Maybe we need to ensure their is no ringing with SoundPoolManager.getInstance().stopRinging();
        SoundPoolManager.getInstance().playDisconnect();
        // TODO: only end the current active call
        _callKeep.endAllCalls();
      } else if (event is CallQualityWarningChanged) {
        logger.d("CALL_QUALITY_WARNING_CHANGED", event);
      } else {
        logger.d("DEFAULT CASE in stream", event);
      }
    });


    await DotEnv().load('.env');
    final accessTokenUrl = DotEnv().env['ACCESS_TOKEN_URL'];

    TwilioProgrammableVoice().setUp(accessTokenUrl: accessTokenUrl, headers : {"TestHeader": "I'm a test header"}).then((isRegistrationValid) {
      logger.d("registration is valid: " + isRegistrationValid.toString());
    });
  }



  Future<bool> checkDefaultPhoneAccount() async {
    logger.d('[checkDefaultPhoneAccount]');
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();

    if (!hasPhoneAccount) {
      logger.d("Doesn't have phone account, asking for permission");
      // TODO return this when callkeep merge our pull request
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }


    return hasPhoneAccount;
  }

  Future<void> displayMakeCallScreen(
      String targetNumber, String callerDisplayName) async {
    logger.d('[displayMakeCallScreen] called');

    final String callUUID = TwilioProgrammableVoice().getCall.sid;
    await checkDefaultPhoneAccount();

    logger.d(
        '[displayMakeCallScreen] uuid: $callUUID, targetNumber: $targetNumber, displayName: $callerDisplayName');

    // Display a start call screen
    _callKeep.startCall(callUUID, targetNumber, callerDisplayName);
  }

  Future<void> displayIncomingCallInvite(
      String callerNumber, String callerDisplayName) async {
    logger.d('[displayIncomingCallInvite] called');

    // TODO: review how getCall works to separate calls and call invites
    final String callUUID = TwilioProgrammableVoice().getCall.sid;
    await checkDefaultPhoneAccount();

    logger.d(
        '[displayIncomingCallInvite] uuid: $callUUID, callerNumber: $callerNumber, displayName: $callerDisplayName');

    _callKeep.displayIncomingCall(callUUID, callerNumber,
        handleType: 'number',
        hasVideo: false,
        localizedCallerName: callerDisplayName);
  }

  @override
  void initState() {
    super.initState();
    print(_firebaseMessaging.getToken());

   initCallKeep(_callKeep);
    _firebaseMessaging.configure(
      onMessage: (Map<String, dynamic> message) async {
        logger.d('[onFirebaseMessage]', message);
        // It's a real push notification
        if (message["notification"]["title"] != null) {}

        // It's a data
        if (message.containsKey("data") && message["data"] != null) {
          // It's a twilio data message
          logger.d("Message contains data", message["data"]);
          if (message["data"].containsKey("twi_message_type")) {
            logger.d("Message is a Twilio Message");

            final dataMap = Map<String, String>.from(message["data"]);

            TwilioProgrammableVoice().handleMessage(data: dataMap);
            logger
                .d("TwilioProgrammableVoice().handleMessage called in main.dart");
          }
        }
      },
      onBackgroundMessage: Platform.isIOS ? null : myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        logger.d("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        logger.d("onResume: $message");
      },
    );

  setUpTwilioProgrammableVoice();
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
                  onPressed: () async {
                    await DotEnv().load('.env');
                    final accessTokenUrl = DotEnv().env['ACCESS_TOKEN_URL'];

                    final isRegistrationValid = await _twilioProgrammableVoice.setUp(accessTokenUrl: accessTokenUrl);
                    print("register c'est bien passé : " + isRegistrationValid.toString());
                  },
                  child: Text('Register')),
              FlatButton(
                  onPressed: () async {
                    final makeCall = await _twilioProgrammableVoice.makeCall(from: "testId", to: "+33787934070");
                    print("makeCall c'est bien passé : " + makeCall.toString());
                  },
                  child: Text('Make call')),
              FlatButton(
                  onPressed: () {
                    _twilioProgrammableVoice.testEventChannel(data: {"data": "test"});
                  },
                  child: Text('Test EventChannel')),
            ],
          )),
    );
  }
}

class TwilioProgrammingVoiceExampleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Twilio Programming Voice Example',
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}
