import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:twilio_programmable_voice/twilio_programmable_voice.dart';

void main() {
  const MethodChannel channel = MethodChannel('twilio_programmable_voice');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await TwilioProgrammableVoice.platformVersion, '42');
  });
}