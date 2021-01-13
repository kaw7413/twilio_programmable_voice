import 'package:workmanager/workmanager.dart';

class WorkmanagerWrapper {
  static bool _initDone = false;
  static String _uniqueName = "uniqueName";
  static String _taskName = "taskName";
  static void callbackDispatcher() {
    Workmanager.executeTask((task, inputData) {
      print("Native called background task"); //simpleTask will be emitted here.
      return Future.value(true);
    });
  }

  static void _ensureInitialisation() {
    if (!_initDone) {
      Workmanager.initialize(
      callbackDispatcher, // The top level function, aka callbackDispatcher
      isInDebugMode: true // If enabled it will post a notification whenever the task is running. Handy for debugging tasks
      );
      _initDone = true;
    }
  }

  static void launchInBg() {
    _ensureInitialisation();
    Workmanager.registerOneOffTask(_uniqueName, _taskName);
  }



}