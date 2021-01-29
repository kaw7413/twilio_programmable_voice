import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:start_jwt/json_web_token.dart';
import 'package:twilio_programmable_voice/src/callback_dispatcher.dart';
import 'package:twilio_programmable_voice/src/injector.dart';

import 'package:twilio_programmable_voice/src/workmanager_wrapper.dart';
import 'package:workmanager/workmanager.dart';

class WorkmanagerMock extends Mock implements Workmanager {}

final int testExp = 1300819380;
final jwt = new JsonWebTokenCodec(secret: "My secret key");
final payload = {
  'exp': testExp,
};
final token = jwt.encode(payload);

final accessTokenUrl = "http://test.me:8000";

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('setUpWorkmanager', () {
    test(
        'should initialize task and cancel all active tasks with registration tag',
        () {
      final mockedWorkmanager =
          mockService<Workmanager>(mock: WorkmanagerMock());
      WorkmanagerWrapper.setUpWorkmanager();

      verify(mockedWorkmanager.initialize(callbackDispatcher,
          isInDebugMode: true));

      verify(mockedWorkmanager.cancelByTag("registration"));
    });
  });

  group('launchJobInBg', () {
    test(
        'it should registerOneOffTask with registration tag and with accessToken in inputData',
        () {
      final mockedWorkmanager =
          mockService<Workmanager>(mock: WorkmanagerMock());

      WorkmanagerWrapper.launchJobInBg(
          accessToken: token, accessTokenUrl: accessTokenUrl);

      verify(mockedWorkmanager.registerOneOffTask(any, "twilio-registration",
          tag: "registration",
          inputData: {WorkmanagerWrapper.BG_URL_DATA_KEY: accessTokenUrl},
          existingWorkPolicy: anyNamed("existingWorkPolicy"),
          initialDelay: anyNamed("initialDelay"),
          constraints: anyNamed("constraints"),
          backoffPolicy: anyNamed("backoffPolicy"),
          backoffPolicyDelay: anyNamed("backoffPolicyDelay")));
    });
  });

  group('getUniqueName', () {
    test('getUniqueName should return a unique value', () {
      final String uniqueName1 = WorkmanagerWrapper.getUniqueName();
      final String uniqueName2 = WorkmanagerWrapper.getUniqueName();
      final bool areTheSame = (uniqueName1 == uniqueName2);

      expect(areTheSame, false);
    });
  });

  group('getDelayBeforeExec', () {
    test('should return a Duration', () {
      final duration =
          WorkmanagerWrapper.getDelayBeforeExec(accessToken: token);
      expect(duration, isA<Duration>());
    });

    test('the duration should be (exp - now) - safe_duration', () {
      var expDate = DateTime.fromMillisecondsSinceEpoch(testExp * 1000);
      Duration expectedDuration = (expDate.difference(DateTime.now()) -
          WorkmanagerWrapper.SAFETY_DURATION);

      final duration =
          WorkmanagerWrapper.getDelayBeforeExec(accessToken: token);

      // in seconds because we can't be more precise (execution time)
      expect(duration.inSeconds, expectedDuration.inSeconds);
    });
  });
}
