class UndefinedFcmTokenStrategyException implements Exception {
  String message = "The specified fcm token strategy isn't defined";

  UndefinedFcmTokenStrategyException();

  @override
  String toString() => 'UndefinedFcmTokenStrategy($message)';
}

class UndefinedAccessTokenStrategyException implements Exception {
  final String message = "The specified access token strategy isn't defined";

  UndefinedAccessTokenStrategyException();

  @override
  String toString() => 'UndefinedAccessTokenStrategy($message)';
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

class SettingNonExistingStrategies {
  final String message = "The only strategies you can set are the BoxKeys.FCM_TOKEN_STRATEGY and the BoxKeys.ACCESS_TOKEN_STRATEGY";

  SettingNonExistingStrategies();

  @override
  String toString() => 'SettingNonExistingStrategies($message)';
}