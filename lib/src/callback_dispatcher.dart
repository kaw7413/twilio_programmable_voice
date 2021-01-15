import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';

void callbackDispatcher() {
  Workmanager.executeTask((task, inputData) async {
    final bool isRegistrationValid = await TwilioProgrammableVoice.registerVoice(inputData[TwilioProgrammableVoice.BG_URL_DATA_KEY]);
    return isRegistrationValid;
  });
}