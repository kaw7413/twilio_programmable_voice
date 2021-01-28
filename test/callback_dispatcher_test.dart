import 'package:flutter_test/flutter_test.dart';

import 'package:twilio_programmable_voice/src/callback_dispatcher.dart';

void main() {
  test('callbackDispatcher should be a function', () {
    expect(callbackDispatcher, isA<Function>());
  });
}