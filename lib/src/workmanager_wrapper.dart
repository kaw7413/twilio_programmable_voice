import 'package:background_fetch/background_fetch.dart';

import 'package:meta/meta.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

import 'callback_dispatcher.dart';

abstract class WorkmanagerWrapper {
  static const SAFETY_DURATION = Duration(seconds: 15);
  static const BG_BACKOFF_POLICY_DELAY = Duration(seconds: 15);
  static const BG_URL_DATA_KEY = "accessTokenUrl";

  static Future<void> launchJobInBg(
      {@required String accessTokenUrl, @required String accessToken}) async {
    /* TODO: Check every x hours if the deviceToken is different from what
     we've stored previously. If it did changed, we must register to Twilio
     with a freshly created accessToken.

     Note: We should also ask a new token when credentials changed, hence
     when the PKPushRegistry tell us the credentials changed (device token)
     The exact same logic should we donc in FireMessaging (Android only), when
     the Fcm token changed.
    */

    /*BackgroundFetch.configure(
        BackgroundFetchConfig(
            minimumFetchInterval: 15,
            stopOnTerminate: false,
            startOnBoot: true,
            enableHeadless: true,
            requiresBatteryNotLow: false,
            requiresCharging: false,
            requiresStorageNotLow: false,
            requiresDeviceIdle: false,
            requiredNetworkType: NetworkType.ANY), (String taskId) async {
      await taskHandler("twilio-access-token-registration", {BG_URL_DATA_KEY: accessTokenUrl});
      print("[BackgroundFetch] Event received $taskId");
      // IMPORTANT:  You must signal completion of your task or the OS can punish your app
      // for taking too long in the background.
      BackgroundFetch.finish(taskId);
    }, (String taskId) async {
      // <-- Task timeout handler.
      // This task has exceeded its allowed running-time.  You must stop what you're doing and immediately .finish(taskId)
      print("[BackgroundFetch] TASK TIMEOUT taskId: $taskId");
      BackgroundFetch.finish(taskId);
    }).then((value) => print("state $value")); */
  }

  @visibleForTesting
  static Duration getDelayBeforeExec({@required String accessToken}) {
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    Duration duration = expirationDate.difference(DateTime.now());

    return duration - SAFETY_DURATION;
  }
}
