import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:mockito/mockito.dart';

import 'package:twilio_programmable_voice/src/box_service.dart';
import 'package:twilio_programmable_voice/src/box_utils.dart';
import 'package:twilio_programmable_voice/src/token_service.dart';
import 'package:twilio_programmable_voice/src/injector.dart';

class MockBoxService extends Mock implements BoxService {}
class MockTokenService extends Mock implements TokenService {}
class MockBox extends Mock implements Box {}

MockBox mockBox;
final headers = {"data": "test"};
final token = "fakeToken";

void main() {
  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockBox = MockBox();
    mockService<BoxService>(mock: MockBoxService());
    when(mockBox.get(BoxKeys.FCM_TOKEN_STRATEGY)).thenReturn(FcmTokenStrategy.FIREBASE_MESSAGING);
    when(mockBox.get(BoxKeys.HEADERS)).thenReturn({});
    when(getService<BoxService>().getBox())
        .thenAnswer((_) async => mockBox);
  });

  // group('fcmToken related', () {
  //   test('It return a string with firebaseMessaging', () async {
  //     final real = TokenService();
  //     mockService<TokenService>(mock: MockTokenService());
  //     when(getService<TokenService>().fcmTokenStrategyBinder()).thenAnswer((_) => real.fcmTokenStrategyBinder());
  //     final tmp = await getService<TokenService>().fcmTokenStrategyBinder();
  //     print(tmp);
  //     expect(tmp, "toto");
  //     // It should throw an error
  //   });
  //
  //   test('It should throw an error with an undefined strategy', () {
  //
  //   });
  //   // It throw an error with unkow strategy
  // });

  group('box related', () {
    test('setHeaders should access Box', () async {
      await getService<TokenService>().setHeaders(headers: headers);
      verify(getService<BoxService>().getBox());
      verify(mockBox.put(BoxKeys.HEADERS, headers));
    });

    test('getHeaders should read headers from Hive box', () async {
      // TODO make return something
      await getService<TokenService>().getHeaders();
      verify(getService<BoxService>().getBox());
      verify(mockBox.get(BoxKeys.HEADERS));
    });

    test('persistAccessToken should access Box', () async {
      await getService<TokenService>().persistAccessToken(accessToken: token);
      verify(getService<BoxService>().getBox());
      verify(mockBox.put(BoxKeys.ACCESS_TOKEN, token));
    });

    test('removeAccessToken should access Box', () async {
      await getService<TokenService>().removeAccessToken();
      verify(getService<BoxService>().getBox());
      verify(mockBox.delete(BoxKeys.ACCESS_TOKEN));
    });
  });
}