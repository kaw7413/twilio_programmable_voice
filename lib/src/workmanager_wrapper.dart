import 'twilio_programmable_voice.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerWrapper {
  static bool _initDone = false;
  static const String _uniqueName = "uniqueName";
  static const String _taskName = "taskName";
  static void callbackDispatcher() {
    Workmanager.executeTask((task, inputData) {
      print("Native called background task");
      return Future.value(true);
    });
  }

  static void _ensureInitialisation() {
    if (!_initDone) {
      Workmanager.initialize(
      callbackDispatcher,
      isInDebugMode: true // if true, display notification when job is exec
      );
      _initDone = true;
    }
  }

  static void launchInBg(String accessToken) {
    _ensureInitialisation();
    // Need to discuss about the ExistingWorkPolicy
    Workmanager.registerOneOffTask(_uniqueName, _taskName,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(
          networkType: NetworkType.connected
        ),
        initialDelay: _getDelayBeforeExec(accessToken));
  }

  static Duration _getDelayBeforeExec(String accessToken) {
    print("[GetDelay]");
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    Duration duration = expirationDate.difference(DateTime.now());
    print("Will be called in: "+duration.inSeconds.toString()+"s");
    // maybe remove ~15s to the duration
    return duration;
  }



}