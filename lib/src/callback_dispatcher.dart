import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';
import 'token_manager.dart';
import 'workmanager_wrapper.dart';

Future<void> callbackDispatcher() async {
  Workmanager.executeTask((task, inputData)async {
    await TokenManager.removeAccessToken();
    final bool isRegistrationValid = await TwilioProgrammableVoice.registerVoice(accessTokenUrl : inputData[WorkmanagerWrapper.BG_URL_DATA_KEY]);
    return isRegistrationValid;
  });
}