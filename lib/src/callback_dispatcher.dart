import 'dart:io';

import 'package:workmanager/workmanager.dart';

import 'twilio_programmable_voice.dart';
import 'token_service.dart';
import 'workmanager_wrapper.dart';
import 'injector.dart';

/*
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
