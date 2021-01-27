import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';

import 'package:twilio_programmable_voice/src/box_wrapper.dart';

void main() {
  test('Should open a box', () async {
    final bool isOpen = await BoxWrapper.getInstance().then((box) => Hive.isBoxOpen("TwilioProgrammableVoiceBox"));
    expect(isOpen, true);
  });
  
  test('Should return a Box object', () async {
    final box = await BoxWrapper.getInstance().then((box) => box);
    expect(box, isA<Box>());
  });
}