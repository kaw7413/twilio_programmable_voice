import 'package:flutter_test/flutter_test.dart';
import 'package:start_jwt/json_web_token.dart';

import 'package:twilio_programmable_voice/src/workmanager_wrapper.dart';

final int testExp = 1300819380;
final jwt = new JsonWebTokenCodec(secret: "My secret key");
final payload = {
  'exp': testExp,
};
final token = jwt.encode(payload);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

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
      final duration = WorkmanagerWrapper.getDelayBeforeExec(accessToken: token);
      expect(duration, isA<Duration>());
    });

    test('the duration should be (exp - now) - safe_duration', () {
      var expDate = DateTime.fromMillisecondsSinceEpoch(testExp * 1000);
      Duration expectedDuration = (expDate.difference(DateTime.now()) -
          WorkmanagerWrapper.SAFETY_DURATION);

      final duration = WorkmanagerWrapper.getDelayBeforeExec(accessToken: token);

      // in seconds because we can't be more precise (execution time)
      expect(duration.inSeconds, expectedDuration.inSeconds);
    });
  });
}