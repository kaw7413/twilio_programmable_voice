import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

class BoxWrapper {
  static Future _boxCreated;
  static Box _instance;
  static final box = "accessTokenBox";
  static final key = "accessToken";

  static Future<Box> getInstance() async {
    if (_instance == null) {
      BoxWrapper._internal();
    }

    await BoxWrapper.initializationDone;
    return _instance;
  }

  BoxWrapper._internal() {
    _boxCreated = _createBox();
  }

  _createBox() async {
    await Hive.initFlutter();
    _instance = await Hive.openBox(BoxWrapper.box);
  }

  static Future get initializationDone => BoxWrapper._boxCreated;
}