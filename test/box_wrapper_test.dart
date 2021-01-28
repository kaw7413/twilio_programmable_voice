import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:get_it/get_it.dart';

import 'package:twilio_programmable_voice/src/box_service.dart';
import 'package:twilio_programmable_voice/src/box_utils.dart';

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<BoxService>(BoxService());
  });

  test('Should open a box', () async {
    final bool isOpen = await GetIt.I<BoxService>().getBox().then((box) => Hive.isBoxOpen(BoxKeys.PLUGIN_BOX_NAME));
    expect(isOpen, true);
  });
  
  test('Should return a Box object', () async {
    final box = await GetIt.I<BoxService>().getBox().then((box) => box);
    expect(box, isA<Box>());
  });
}