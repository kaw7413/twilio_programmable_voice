abstract class BoxKeys {
  static const PLUGIN_BOX_NAME = "TwilioProgrammableVoiceBox";
  static const ACCESS_TOKEN = "ACCESS_TOKEN";
  static const ACCESS_TOKEN_STRATEGY = "ACCESS_TOKEN_STRATEGY";
  static const FCM_TOKEN_STRATEGY = "FCM_TOKEN_STRATEGY";
  static const HEADERS = "HEADERS";
}

abstract class AccessTokenStrategy {
  static const GET = "GET";
}

abstract class FcmTokenStrategy {
  static const FIREBASE_MESSAGING = "FIREBASE_MESSAGING";
}