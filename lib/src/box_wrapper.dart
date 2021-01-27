import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'box_utils.dart';

class BoxWrapper {
  static Box _instance;
  static const _BOX = "TwilioProgrammableVoiceBox";
  static Future _boxCreated;

  static Future<Box> getInstance() async {
    if (_instance == null) {
      BoxWrapper._internal();
    }

    await _initializationDone;
    return _instance;
  }

  BoxWrapper._internal() {
    _boxCreated = _createBox();
  }

  _createBox() async {
    await Hive.initFlutter();
    _instance = await Hive.openBox(BoxKeys.PLUGIN_BOX_NAME);
  }

  static Future get _initializationDone => _boxCreated;
}