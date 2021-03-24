import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

Future<void> backgroundMessageHandler(dynamic message) async {
  // It's a data
  if (message.containsKey("data") && message["data"] != null) {
    // It's a twilio data message
    print("In APP listener Message contains data");
    if (message["data"].containsKey("twi_message_type")) {
      print("Message is a Twilio Message");

      final dataMap = Map<String, String>.from(message["data"]);

      // Handle Twilio Message
      await TwilioProgrammableVoice().handleMessage(data: dataMap);

      print("handleMessage called in main.dart");
    }
  }
}