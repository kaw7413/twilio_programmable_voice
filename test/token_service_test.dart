import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';
import 'package:get_it/get_it.dart';

import 'package:twilio_programmable_voice/src/box_service.dart';
import 'package:twilio_programmable_voice/src/token_manager.dart';

class MockBoxService extends Mock implements BoxService {}
class MockBox extends Mock implements Box {}

void main() {
  setUpAll(() {
    GetIt.I.registerSingleton<BoxService>(MockBoxService());
    when(GetIt.I<BoxService>().getBox())
        .thenAnswer((_) async => MockBox());
  });

  test('Testing GetIt mock', () {
    TokenManager.removeAccessToken();

    verify(GetIt.I<BoxService>().getBox());
  });
}