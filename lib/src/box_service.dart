import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'box_utils.dart';

class BoxService {
  Box _box;
  Future _boxCreated;

  BoxService() {
    _boxCreated = _createBox();
  }

  _createBox() async {
    await Hive.initFlutter();
    _box = await Hive.openBox(BoxKeys.PLUGIN_BOX_NAME);
  }

  Future<Box> getBox() async {
    await _boxCreated;
    return _box;
  }
}