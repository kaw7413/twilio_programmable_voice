import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:twilio_programmable_voice/src/box_service.dart';
import 'package:twilio_programmable_voice/src/box_utils.dart';
import 'package:twilio_programmable_voice/src/injector.dart';

void main() {
  test('Should open a box', () async {
    final bool isOpen = await getService<BoxService>().getBox().then((box) => Hive.isBoxOpen(BoxKeys.PLUGIN_BOX_NAME));
    expect(isOpen, true);
  });
  
  test('Should return a Box object', () async {
    final box = await getService<BoxService>().getBox().then((box) => box);
    expect(box, isA<Box>());
  });
}