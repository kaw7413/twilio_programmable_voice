import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';
import 'workmanager_wrapper.dart';

void callbackDispatcher() {
    Workmanager.executeTask((task, inputData) async {
      final bool isRegistrationValid = await TwilioProgrammableVoice.registerVoice(accessTokenUrl : inputData[WorkmanagerWrapper.BG_URL_DATA_KEY]);
      print('[callbackDispatcher]');
      print(isRegistrationValid);
      return isRegistrationValid;
    });
}
