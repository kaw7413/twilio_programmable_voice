import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';
import 'token_service.dart';
import 'workmanager_wrapper.dart';
import 'injector.dart';

Future<void> callbackDispatcher() async {
  getService<Workmanager>().executeTask(taskHandler);
}

Future<bool> taskHandler(String task, Map<String, dynamic> inputData) async {
  await getService<TokenService>().removeAccessToken();
  final bool isRegistrationValid = await getService<TwilioProgrammableVoice>().registerVoice(
      accessTokenUrl: inputData[WorkmanagerWrapper.BG_URL_DATA_KEY]);
  return isRegistrationValid;
}
