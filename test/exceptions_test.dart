import 'package:flutter_test/flutter_test.dart';

import 'package:twilio_programmable_voice/src/exceptions.dart';

void main() {
  test('UndefinedFcmTokenStrategyException, should have a nice toString method',
      () {
    final undefinedFcmTokenStrategyException =
        UndefinedFcmTokenStrategyException();
    final message = undefinedFcmTokenStrategyException.message;
    expect(undefinedFcmTokenStrategyException.toString(),
        "UndefinedFcmTokenStrategyException($message)");
  });

  test(
      'UndefinedAccessTokenStrategyException, should have a nice toString method',
      () {
    final undefinedAccessTokenStrategyException =
        UndefinedAccessTokenStrategyException();
    final message = undefinedAccessTokenStrategyException.message;
    expect(undefinedAccessTokenStrategyException.toString(),
        "UndefinedAccessTokenStrategyException($message)");
  });

  test(
      'NoValuePassToAccessTokenStrategyException, should have a nice toString method',
      () {
    final noValuePassToAccessTokenStrategyException =
        NoValuePassToAccessTokenStrategyException();
    final message = noValuePassToAccessTokenStrategyException.message;
    expect(noValuePassToAccessTokenStrategyException.toString(),
        "NoValuePassToAccessTokenStrategyException($message)");
  });

  test(
      'NoValuePassFcmTokenStrategyException, should have a nice toString method',
      () {
    final noValuePassFcmTokenStrategyException =
        NoValuePassFcmTokenStrategyException();
    final message = noValuePassFcmTokenStrategyException.message;
    expect(noValuePassFcmTokenStrategyException.toString(),
        "NoValuePassFcmTokenStrategyException($message)");
  });

  test(
      'SettingNonExistingStrategiesException, should have a nice toString method',
      () {
    final settingNonExistingStrategiesException =
        SettingNonExistingStrategiesException();
    final message = settingNonExistingStrategiesException.message;
    expect(settingNonExistingStrategiesException.toString(),
        "SettingNonExistingStrategiesException($message)");
  });

  test('GettingUnknownServiceException, should have a nice toString method',
      () {
    final gettingUnknownServiceException = GettingUnknownServiceException();
    final message = gettingUnknownServiceException.message;
    expect(gettingUnknownServiceException.toString(),
        "GettingUnknownServiceException($message)");
  });
}
