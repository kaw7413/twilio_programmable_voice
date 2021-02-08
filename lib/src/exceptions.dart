class UndefinedFcmTokenStrategyException implements Exception {
  String message = "The specified fcm token strategy isn't defined";

  UndefinedFcmTokenStrategyException();

  @override
  String toString() => 'UndefinedFcmTokenStrategyException($message)';
}

class UndefinedAccessTokenStrategyException implements Exception {
  final String message = "The specified access token strategy isn't defined";

  UndefinedAccessTokenStrategyException();

  @override
  String toString() => 'UndefinedAccessTokenStrategyException($message)';
}

class NoValuePassToAccessTokenStrategyException implements Exception {
  final String message = "You need to pass a value to the key BoxKeys.ACCESS_TOKEN_STRATEGY if you want to add a custom config";

  NoValuePassToAccessTokenStrategyException();

  @override
  String toString() => 'NoValuePassToAccessTokenStrategyException($message)';
}

class NoValuePassFcmTokenStrategyException implements Exception {
  final String message = "You need to pass a value to the key BoxKeys.FCM_TOKEN_STRATEGY if you want to add a custom config";

  NoValuePassFcmTokenStrategyException();

  @override
  String toString() => 'NoValuePassFcmTokenStrategyException($message)';
}

class SettingNonExistingStrategiesException {
  final String message = "The only strategies you can set are the BoxKeys.FCM_TOKEN_STRATEGY and the BoxKeys.ACCESS_TOKEN_STRATEGY";

  SettingNonExistingStrategiesException();

  @override
  String toString() => 'SettingNonExistingStrategiesException($message)';
}

class GettingUnknownServiceException {
  final String message = "You try to instantiate an unknown service, you can only instantiate services of type: BoxService, TokenService or WorkManager";

  GettingUnknownServiceException();

  @override
  String toString() => 'GettingUnknownServiceException($message)';
}

class AccessTokenUrlIsNullException {
  final String message = "You must provide a valid accessTokenUrl, null was provided";

  AccessTokenUrlIsNullException();

  @override
  String toString() => 'AccessTokenUrlIsNullException($message)';
}