import 'package:callkeep/callkeep.dart';
import 'package:dio/dio.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';
import 'utils/callkeep_config.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  // It's a data
  if (message.containsKey("data") && message["data"] != null) {
    // It's a twilio data message
    print("Message contains data");
    if (message["data"].containsKey("twi_message_type")) {
      print("Message is a Twilio Message");

      final dataMap = Map<String, String>.from(message["data"]);
      final callUUID = TwilioProgrammableVoice.getCall.sid;

      _callKeep.on(CallKeepPerformAnswerCallAction(),
              (CallKeepPerformAnswerCallAction event) async {
            print(
                'backgroundMessage: CallKeepPerformAnswerCallAction ${event.callUUID}');

            _callKeep.startCall(event.callUUID, TwilioProgrammableVoice.getCall.from, "callerName");
            // Generate accessToken from backend.
            // http://localhost:3000/accessToken/test
            final tokenResponse =
            await Dio().get("http://host:3000/accessToken/testId");

            print("[TOKEN RESPONSE DATA]");
            print(tokenResponse.data);
            // Get fcmToken.
            final fcmToken = await FirebaseMessaging().getToken();
            print("[FCM TOKEN]");
            print(fcmToken);

            await TwilioProgrammableVoice.registerVoice(
                tokenResponse.data, fcmToken);
            await TwilioProgrammableVoice.handleMessage(dataMap);
            await TwilioProgrammableVoice.answer();

            _callKeep.setCurrentCallActive(callUUID);
          });

      _callKeep.on(CallKeepPerformEndCallAction(),
              (CallKeepPerformEndCallAction event) async {
            print(
                'backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');

            // Generate accessToken from backend.
            // http://localhost:3000/accessToken/test
            final tokenResponse =
            await Dio().get("http://host:3000/accessToken/testId");

            print("[TOKEN RESPONSE DATA]");
            print(tokenResponse.data);
            // Get fcmToken.
            final fcmToken = await FirebaseMessaging().getToken();
            print("[FCM TOKEN]");
            print(fcmToken);

            await TwilioProgrammableVoice.registerVoice(tokenResponse.data, fcmToken);
            await TwilioProgrammableVoice.handleMessage(dataMap);
            await TwilioProgrammableVoice.reject();
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