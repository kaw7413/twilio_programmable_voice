import 'package:meta/meta.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:workmanager/workmanager.dart';
import 'package:uuid/uuid.dart';

import 'callback_dispatcher.dart';

abstract class WorkmanagerWrapper {
  static const _BG_UNIQUE_NAME = "registrationJob";
  static const _BG_TASK_NAME = "twilio-registration";
  static const _BG_TAG = "registration";
  static const _SAFETY_DURATION = Duration(seconds: 15);
  static const _BG_BACKOFF_POLICY_DELAY = Duration(seconds: 15);
  static const BG_URL_DATA_KEY = "accessTokenUrl";

  static void setUpWorkmanager() {
    Workmanager.initialize(
        callbackDispatcher,
        isInDebugMode: true
    );
    Workmanager.cancelByTag(_BG_TAG);
  }

  static Future<void> launchJobInBg(
      {@required String accessTokenUrl, @required String accessToken}) async {
    await Workmanager.registerOneOffTask(getUniqueName(), _BG_TASK_NAME,
        tag: _BG_TAG,
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: _BG_BACKOFF_POLICY_DELAY,
        inputData: {
          BG_URL_DATA_KEY: accessTokenUrl
        },
        initialDelay: WorkmanagerWrapper.getDelayBeforeExec(accessToken: accessToken));
  }

  static Duration getDelayBeforeExec({@required String accessToken}) {
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    Duration duration = expirationDate.difference(DateTime.now());

    return duration - _SAFETY_DURATION;
  }

  static String getUniqueName() {
    return _BG_UNIQUE_NAME + Uuid().v1();
  }
}