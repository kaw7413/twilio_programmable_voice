import 'package:callkeep/callkeep.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

import 'utils/callkeep_config.dart';

final FlutterCallkeep _callKeep = FlutterCallkeep();
bool _callKeepInited = false;

Future<dynamic> myBackgroundMessageHandler(Map<String, dynamic> message) async {
  await DotEnv().load('.env');
  final accessTokenUrl = DotEnv().env['ACCESS_TOKEN_URL'];
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

            await TwilioProgrammableVoice.setUp(accessTokenUrl: accessTokenUrl);
            await TwilioProgrammableVoice.handleMessage(data: dataMap);
            await TwilioProgrammableVoice.answer();

            _callKeep.setCurrentCallActive(callUUID);
          });

      _callKeep.on(CallKeepPerformEndCallAction(),
              (CallKeepPerformEndCallAction event) async {
            print(
                'backgroundMessage: CallKeepPerformEndCallAction ${event.callUUID}');

            await TwilioProgrammableVoice.setUp(accessTokenUrl: accessTokenUrl);
            await TwilioProgrammableVoice.handleMessage(data: dataMap);
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