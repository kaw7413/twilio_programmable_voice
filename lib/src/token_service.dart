import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';
import 'package:twilio_programmable_voice/src/box_service.dart';

import 'box_utils.dart';
import 'injector.dart';

class TokenService {
  static const _DEFAULT_CONFIG = { BoxKeys.ACCESS_TOKEN_STRATEGY : AccessTokenStrategy.GET, BoxKeys.FCM_TOKEN_STRATEGY : FcmTokenStrategy.FIREBASE_MESSAGING };
  static const _NO_ACCESS_TOKEN_STRATEGY = "You need to pass a value to the key BoxKeys.ACCESS_TOKEN_STRATEGY if you want to add a custom config";
  static const _UNDEFINED_ACCESS_TOKEN_STRATEGY = "The specified access token strategy isn't defined";
  static const _NO_FCM_TOKEN_STRATEGY = "You need to pass a value to the key BoxKeys.FCM_TOKEN_STRATEGY if you want to add a custom config";
  static const _UNDEFINED_FCM_TOKEN_STRATEGY = "The specified fcm token strategy isn't defined";

  TokenService([Map<String, String> tokenManagerStrategies, Map<String, dynamic> headers]) {
    init(tokenManagerStrategies, headers);
  }

  Future<void> init(Map<String, String> tokenManagerStrategies, Map<String, dynamic> headers) async {
    bool areStrategiesDefined = await _areStrategiesDefined();
    if (tokenManagerStrategies != null) {
      _setUpStrategies(config: tokenManagerStrategies);
    } else if (!areStrategiesDefined) {
      _setUpStrategies(config: _DEFAULT_CONFIG);
    }

    if (headers != null) {
      setHeaders(headers: headers);
    }
  }
  
  Future<void> _setUpStrategies({@required Map<String, Object> config}) async {
    await getService<BoxService>().getBox().then((box) {
      if (config[BoxKeys.ACCESS_TOKEN_STRATEGY] != null) {
        box.put(BoxKeys.ACCESS_TOKEN_STRATEGY, config[BoxKeys.ACCESS_TOKEN_STRATEGY]);
      } else {
        throw(_NO_ACCESS_TOKEN_STRATEGY);
      }

      if (config[BoxKeys.FCM_TOKEN_STRATEGY] != null) {
        box.put(BoxKeys.FCM_TOKEN_STRATEGY, config[BoxKeys.FCM_TOKEN_STRATEGY]);
      } else {
        throw(_NO_FCM_TOKEN_STRATEGY);
      }
    });
  }

  Future<bool> _areStrategiesDefined() async {
    return await getService<BoxService>().getBox().then((box) {
      return (box.get(BoxKeys.ACCESS_TOKEN_STRATEGY) != null && box.get(BoxKeys.FCM_TOKEN_STRATEGY) != null);
    });
  }

  Future<String> getAccessToken({@required String accessTokenUrl}) async {
    String accessToken = await getService<BoxService>().getBox().then((box) => box.get(BoxKeys.ACCESS_TOKEN));
    if (accessToken == null) {
      accessToken = await _accessTokenStrategyBinder(accessTokenUrl: accessTokenUrl);
    }

    return accessToken;
  }

  Future<String> _accessTokenStrategyBinder({@required String accessTokenUrl}) async {
    return await getService<BoxService>().getBox().then((box) async {
      if (box.get(BoxKeys.ACCESS_TOKEN_STRATEGY) == AccessTokenStrategy.GET) {
        return await _httpGetAccessTokenStrategy(accessTokenUrl: accessTokenUrl);
      } else {
        throw(_UNDEFINED_ACCESS_TOKEN_STRATEGY);
      }
    });
  }

  Future<String> _httpGetAccessTokenStrategy({@required String accessTokenUrl}) async {
    final headers = await getHeaders();
    final tokenResponse = await Dio().get(accessTokenUrl, options: Options(headers: headers));
    return tokenResponse.data;
  }

  Future<void> persistAccessToken({@required String accessToken}) async {
    await getService<BoxService>().getBox().then((box) => box.put(BoxKeys.ACCESS_TOKEN, accessToken));
  }

  Future<void> removeAccessToken() async {
    await getService<BoxService>().getBox().then((box) => box.delete(BoxKeys.ACCESS_TOKEN));
  }

  @visibleForTesting
  Future<void> setHeaders({@required Map<String, dynamic> headers}) async {
    await getService<BoxService>().getBox().then((box) => box.put(BoxKeys.HEADERS, headers));
  }

  @visibleForTesting
  Future<Map<String, dynamic>> getHeaders() async {
    final headers = await getService<BoxService>().getBox().then((box) => box.get(BoxKeys.HEADERS));

    return (headers != null) ? Map<String, dynamic>.from(headers) : null;
  }

  Future<String> getFcmToken() async {
    return await fcmTokenStrategyBinder();
  }

  @visibleForTesting
  Future<String> fcmTokenStrategyBinder() async {
    return await getService<BoxService>().getBox().then((box) {
      if (box.get(BoxKeys.FCM_TOKEN_STRATEGY) == FcmTokenStrategy.FIREBASE_MESSAGING) {
        print("Im here");
        return firebaseMessagingFcmTokenStrategy();
      } else {
        throw(_UNDEFINED_FCM_TOKEN_STRATEGY);
      }
    });
  }

  @visibleForTesting
  Future<String> firebaseMessagingFcmTokenStrategy() {
    return FirebaseMessaging().getToken();
  }
}