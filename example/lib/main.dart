import 'dart:async';

import 'package:callkeep/callkeep.dart';
import 'package:dio/dio.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:logger/logger.dart';
import 'callkeep_functions.dart';
import 'background_message_handler.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

final logger = Logger();

void main() async {
  // Change this to swap log levels
  Logger.level = Level.verbose;

  await DotEnv().load('.env');

  // TODO: Verify if it's still needed
  WidgetsFlutterBinding.ensureInitialized();

  runApp(TwilioProgrammingVoiceExampleApp());
}

class HomePage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging();
  final FlutterCallkeep _callKeep = FlutterCallkeep();

  Future<void> registerVoice() async {
    // Generate accessToken from the /server application.
    // You can edit the URL to whatever backend you're using to authorize users
    final accessTokenUrl = DotEnv().env['ACCESS_TOKEN_URL'];
    if (accessTokenUrl == null) {
      throw ("ACCESS_TOKEN_URL is not defined in .env");
    }

    final tokenResponse = await Dio().get(accessTokenUrl);
    logger.d("[TOKEN RESPONSE DATA]", tokenResponse.data);

    // Get fcmToken.
    final fcmToken = await _firebaseMessaging.getToken();
    logger.d("[FCM TOKEN]", fcmToken);

    // This must be called when the user is authorized to receive and make calls
    TwilioProgrammableVoice.registerVoice(tokenResponse.data, fcmToken);
  }

  Future<void> checkDefaultPhoneAccount() async {
    logger.d('[checkDefaultPhoneAccount]');
    final bool hasPhoneAccount = await _callKeep.hasPhoneAccount();

    if (!hasPhoneAccount) {
      logger.d("Doesn't have phone account, asking for permission");
      await _callKeep.hasDefaultPhoneAccount(context, <String, dynamic>{
        'alertTitle': 'Permissions required',
        'alertDescription':
            'This application needs to access your phone accounts',
        'cancelButton': 'Cancel',
        'okButton': 'ok',
      });
    }
  }

  Future<void> displayMakeCallScreen(
      String targetNumber, String callerDisplayName) async {
    logger.d('[makeCall]');

    final String callUUID = TwilioProgrammableVoice.getCall.sid;
    await checkDefaultPhoneAccount();

    logger.d(
        '[makeCall] uuid: $callUUID, number: $targetNumber, displayName: $callerDisplayName');

    // Display a start call screen
    _callKeep.startCall(callUUID, targetNumber, callerDisplayName);
  }

  Future<void> displayIncomingCallInvite(
      String callerNumber, String callerDisplayName) async {
    logger.d('[displayIncomingCallInvite]');

    // TODO: review how getCall works to separate calls and call invites
    final String callUUID = TwilioProgrammableVoice.getCall.sid;
    await checkDefaultPhoneAccount();

    logger.d(
        '[displayIncomingCallInvite] uuid: $callUUID, number: $callerNumber, displayName: $callerDisplayName');

    _callKeep.displayIncomingCall(callUUID, callerNumber,
        handleType: 'number',
        hasVideo: false,
        localizedCallerName: callerDisplayName);
  }

  @override
  void initState() {
    super.initState();
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

            TwilioProgrammableVoice.handleMessage(dataMap);
            logger
                .d("TwilioProgrammableVoice.handleMessage called in main.dart");
          }
        }
      },
      onBackgroundMessage: myBackgroundMessageHandler,
      onLaunch: (Map<String, dynamic> message) async {
        logger.d("onLaunch: $message");
      },
      onResume: (Map<String, dynamic> message) async {
        logger.d("onResume: $message");
      },
    );

    // TODO: maybe export this so it can be awaited
    TwilioProgrammableVoice.requestMicrophonePermissions().then(logger.d);
    TwilioProgrammableVoice.callStatusStream.listen((event) async {
      logger.d("[TwilioProgrammableVoice Event]");

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
        // TwilioProgrammableVoice.getCall.to and TwilioProgrammableVoice.getCall.from are always null when making a call
        // TODO replace brut phone number with TwilioProgrammableVoice.getCall.to
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

        // @TODO: only end the current active call
        _callKeep.endAllCalls();
      } else if (event is CallQualityWarningChanged) {
        logger.d("CALL_QUALITY_WARNING_CHANGED", event);
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
