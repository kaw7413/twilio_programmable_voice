import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:workmanager/workmanager.dart';

import 'package:twilio_programmable_voice/src/callback_dispatcher.dart';
import 'package:twilio_programmable_voice/src/injector.dart';
import 'package:twilio_programmable_voice/src/token_service.dart';
import 'package:twilio_programmable_voice/src/twilio_programmable_voice.dart';
import 'package:twilio_programmable_voice/src/workmanager_wrapper.dart';


class WorkmanagerMock extends Mock implements Workmanager {}
class TokenServiceMock extends Mock implements TokenService {}
class TwilioProgrammableVoiceMock extends Mock implements TwilioProgrammableVoice {}

void main() {
  setUpAll(() {
    mockService<Workmanager>(mock: WorkmanagerMock());
    mockService<TokenService>(mock: TokenServiceMock());
    mockService<TwilioProgrammableVoice>(mock: TwilioProgrammableVoiceMock());
    when(getService<TwilioProgrammableVoice>().registerVoice(accessTokenUrl: "test"))
        .thenAnswer((_) async => true);
  });

  test(
      'callbackDispatcher should call Workmanager.executeTask with the taskHandler',
      () {
    expect(callbackDispatcher, isA<Function>());
    callbackDispatcher();
    verify(getService<Workmanager>().executeTask(taskHandler));
  });

  test(
    'taskHandler function should return a bool', () async {
      final isRegistrationValid = await taskHandler(null, {WorkmanagerWrapper.BG_URL_DATA_KEY: "test"});
      expect(isRegistrationValid, true);
  });
}
