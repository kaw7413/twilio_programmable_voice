import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';
import 'token_service.dart';
import 'workmanager_wrapper.dart';
import 'injector.dart';

Future<void> callbackDispatcher() async {
  Workmanager().executeTask((task, inputData)async {
    // TODO services should be init
    await getService<TokenService>().removeAccessToken();
    final bool isRegistrationValid = await TwilioProgrammableVoice.registerVoice(accessTokenUrl : inputData[WorkmanagerWrapper.BG_URL_DATA_KEY]);
    return isRegistrationValid;
  });
}