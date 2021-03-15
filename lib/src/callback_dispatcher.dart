import 'twilio_programmable_voice.dart';
import 'token_service.dart';
import 'workmanager_wrapper.dart';
import 'injector.dart';

/**
  TODO: the task should be updated so now it compare deviceToken and only register
  if those changed.
*/
Future<bool> taskHandler(String task, Map<String, dynamic> inputData) async {
  await getService<TokenService>().removeAccessToken();

  final bool isRegistrationValid = await TwilioProgrammableVoice()
      .registerVoice(
          accessTokenUrl: inputData[WorkmanagerWrapper.BG_URL_DATA_KEY]);

  return isRegistrationValid;
}

/// Background message (notification) handler for Android only.
///
/// iOS has its own native handler (platform specific code).
Future<void> backgroundMessageHandler(dynamic message) async {
  // It's a data
  if (message.containsKey("data") && message["data"] != null) {
    // It's a twilio data message
    print("Message contains data");
    if (message["data"].containsKey("twi_message_type")) {
      print("Message is a Twilio Message");

      final dataMap = Map<String, String>.from(message["data"]);

      // Handle Twilio Message
      await TwilioProgrammableVoice().handleMessage(data: dataMap);

      print("handleMessage called in main.dart");
    }
  }
}
