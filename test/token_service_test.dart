import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';
import 'package:mockito/mockito.dart';
import 'package:dio/dio.dart';

import 'package:twilio_programmable_voice/src/box_service.dart';
import 'package:twilio_programmable_voice/src/box_utils.dart';
import 'package:twilio_programmable_voice/src/token_service.dart';
import 'package:twilio_programmable_voice/src/injector.dart';
import 'package:twilio_programmable_voice/src/exceptions.dart';

class MockBoxService extends Mock implements BoxService {}

class MockTokenService extends Mock implements TokenService {}

class MockBox extends Mock implements Box {}

class MockDio extends Mock implements Dio {}

MockBox mockBox;
final headers = {"data": "test"};
final token = "fakeToken";
final fakeDioResponse = headers;
final fakeStrategy = "FakeStrategy";

void main() {
  setUp(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    mockBox = MockBox();
    final mockBoxService = mockService<BoxService>(mock: MockBoxService());
    when(mockBox.get(BoxKeys.FCM_TOKEN_STRATEGY))
        .thenReturn(FcmTokenStrategy.FIREBASE_MESSAGING);
    when(mockBox.get(BoxKeys.ACCESS_TOKEN_STRATEGY))
        .thenReturn(AccessTokenStrategy.GET);
    when(mockBox.get(BoxKeys.HEADERS)).thenReturn(headers);
    when(getService<BoxService>().getBox()).thenAnswer((_) async => mockBox);
  });

  group('fcmToken related', () {
    test(
        'It should execute the firebaseMessaging strategy when this strategy is set',
        () async {
      // sadly we can't make something more clever than that because of the mock limitation
      expect(
          () async => await getService<TokenService>().fcmTokenStrategyBinder(),
          throwsA(predicate((err) =>
              err is MissingPluginException &&
              err.message ==
                  'No implementation found for method getToken on channel plugins.flutter.io/firebase_messaging')));
    });

    test('It should throw an exception with an undefined FcmTokenStrategy',
        () async {
      when(mockBox.get(BoxKeys.FCM_TOKEN_STRATEGY))
          .thenReturn("Undefined strategy");

      expect(
          () async => await getService<TokenService>().fcmTokenStrategyBinder(),
          throwsA(
              predicate((err) => err is UndefinedFcmTokenStrategyException)));
    });
  });

  group('accessToken related', () {
    test('it should execute the httpGet strategy when it\'s set', () async {
      final dio = Dio();
      final dioAdapter = DioAdapter();

      dio.httpClientAdapter = dioAdapter;

      dioAdapter.onGet("fakeAccessTokenUrl").reply(200, token);

      final tokenService = TokenService(mock: dio);

      final generatedAccessToken = await tokenService.accessTokenStrategyBinder(
          accessTokenUrl: "fakeAccessTokenUrl");

      expect(generatedAccessToken, token);
    });

    test('It should throw an exception with undefined AccessTokenStrategy', () {
      when(mockBox.get(BoxKeys.ACCESS_TOKEN_STRATEGY))
          .thenReturn("Undefined strategy");

      expect(
          () async => await getService<TokenService>()
              .accessTokenStrategyBinder(accessTokenUrl: "fakeAccessTokenUrl"),
          throwsA(predicate(
              (err) => err is UndefinedAccessTokenStrategyException)));
    });
  });

  group('box related', () {
    test('setHeaders should put headers inside Hive box', () async {
      await getService<TokenService>().setHeaders(headers: headers);

      verify(getService<BoxService>().getBox());
      verify(mockBox.put(BoxKeys.HEADERS, headers));
    });

    test('getHeaders should read headers from Hive box', () async {
      await getService<TokenService>().setHeaders(headers: headers);
      final testHeaders = await getService<TokenService>().getHeaders();

      verify(getService<BoxService>().getBox());
      verify(mockBox.get(BoxKeys.HEADERS));
      expect(testHeaders, headers);
    });

    test('persistAccessToken should put token inside Hive box', () async {
      await getService<TokenService>().persistAccessToken(accessToken: token);

      verify(getService<BoxService>().getBox());
      verify(mockBox.put(BoxKeys.ACCESS_TOKEN, token));
    });

    test('removeAccessToken should delete a value in Hive box', () async {
      await getService<TokenService>().removeAccessToken();

      verify(getService<BoxService>().getBox());
      verify(mockBox.delete(BoxKeys.ACCESS_TOKEN));
    });
  });

  group('strategies utils related', () {
    group('init on token service when no strategies are defined', () {
      test("should setup the default strategy", () async {
        when(mockBox.get(BoxKeys.ACCESS_TOKEN_STRATEGY)).thenReturn(null);

        await getService<TokenService>().init(headers: headers);

        verify(getService<BoxService>().getBox());

        // @TODO: verify box.put 2 times
        // One for accessTokenStrategy
        // Other for fcmTokenStrategy
      });
    });

    group('init when strategy is null', () {
      test(
          "should Throws NoValuePassToAccessTokenStrategyException when stategy is null",
          () {
        expect(
            () async => await getService<TokenService>().init(strategies: {
                  BoxKeys.ACCESS_TOKEN_STRATEGY: null,
                  BoxKeys.FCM_TOKEN_STRATEGY: fakeStrategy
                }),
            throwsA(isA<NoValuePassToAccessTokenStrategyException>()));
      });

      test(
          "should Throws NoValuePassFcmTokenStrategyException when stategy is null",
              () {
            expect(
                    () async => await getService<TokenService>().init(strategies: {
                  BoxKeys.ACCESS_TOKEN_STRATEGY: fakeStrategy,
                  BoxKeys.FCM_TOKEN_STRATEGY: null
                }),
                throwsA(isA<NoValuePassFcmTokenStrategyException>()));
          });
    });

    test('optional header should be set if specify', () async {
      await getService<TokenService>().init(headers: headers);

      verify(getService<BoxService>().getBox());
      // Sadly, we can't check with this level of precision
      // verify(mockBox.put(BoxKeys.HEADERS, headers));
      // this test is already in setHeader test so it's ok

      // Also we can't write something like that
      // verify(getService<TokenService>().setHeaders(headers: headers));
      // because the TokenService isn't mock (and we shouldn't mock it)...
    });

    test('optional strategies should be set if specify', () async {
      await getService<TokenService>().init(strategies: {
        BoxKeys.ACCESS_TOKEN_STRATEGY: fakeStrategy,
        BoxKeys.FCM_TOKEN_STRATEGY: fakeStrategy
      });

      verify(getService<BoxService>().getBox());
      // Same here, we can't write that
      // verify(mockBox.put(BoxKeys.ACCESS_TOKEN_STRATEGY, "FakeStrategy"));
    });

    test('setStrategies should throw an exception if we set an unknow strategy',
        () async {
      expect(
          () async => await getService<TokenService>()
              .setUpStrategies(strategies: {fakeStrategy: fakeStrategy}),
          throwsA(predicate((err) => err is SettingNonExistingStrategies)));
    });

    test('Strategies should be defined by default at init time', () async {
      final areStrategiesDefined = await TokenService().areStrategiesDefined();
      expect(areStrategiesDefined, true);
    });
  });

  group("getAccessToken", ()
  {
    test(
        "should returns what the box contains if the box has something in", () async {
      when(mockBox.get(BoxKeys.ACCESS_TOKEN)).thenReturn(token);

      expect(await getService<TokenService>().getAccessToken(accessTokenUrl: "fakeAccessTokenUrl"), token);
    });

    test("should use strategy to generate an accesstoken and return the dio response", () async {
      when(mockBox.get(BoxKeys.ACCESS_TOKEN)).thenReturn(null);

      final dio = Dio();
      final dioAdapter = DioAdapter();

      dio.httpClientAdapter = dioAdapter;

      dioAdapter.onGet("fakeAccessTokenUrl").reply(200, token);

      final tokenService = TokenService(mock: dio);

      final generatedAccessToken = await tokenService.getAccessToken(
          accessTokenUrl: "fakeAccessTokenUrl");

      expect(generatedAccessToken, token);
    });
  });
}
