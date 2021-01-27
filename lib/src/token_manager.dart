import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:meta/meta.dart';

import 'box_utils.dart';
import 'box_wrapper.dart';
// This might be a "real" class created by factories
// Problem is our plugin need to work in background context
abstract class TokenManager {
  static const _DEFAULT_CONFIG = { BoxKeys.ACCESS_TOKEN_STRATEGY : AccessTokenStrategy.GET, BoxKeys.FCM_TOKEN_STRATEGY : FcmTokenStrategy.FIREBASE_MESSAGING };
  static const _NO_ACCESS_TOKEN_STRATEGY = "You need to pass a value to the key BoxKeys.ACCESS_TOKEN_STRATEGY if you want to add a custom config";
  static const _UNDEFINED_ACCESS_TOKEN_STRATEGY = "The specified access token strategy isn't defined";
  static const _NO_FCM_TOKEN_STRATEGY = "You need to pass a value to the key BoxKeys.FCM_TOKEN_STRATEGY if you want to add a custom config";
  static const _UNDEFINED_FCM_TOKEN_STRATEGY = "The specified fcm token strategy isn't defined";
  
  static Future<void> init(Map<String, String> tokenManagerStrategies, Map<String, dynamic> headers) async {
    bool areStrategiesDefined = await _areStrategiesDefined();
    if (tokenManagerStrategies != null) {
      _setUpStrategies(config: tokenManagerStrategies);
    } else if (!areStrategiesDefined) {
      _setUpStrategies(config: _DEFAULT_CONFIG);
    }

    if (headers != null) {
      _setHeaders(headers: headers);
    }
  }
  
  static Future<void> _setUpStrategies({@required Map<String, Object> config}) async {
    await BoxWrapper.getInstance().then((box) {
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

  static Future<bool> _areStrategiesDefined() async {
    return await BoxWrapper.getInstance().then((box) {
      return (box.get(BoxKeys.ACCESS_TOKEN_STRATEGY) != null && box.get(BoxKeys.FCM_TOKEN_STRATEGY) != null);
    });
  }

  static Future<String> getAccessToken({@required String accessTokenUrl}) async {
    String accessToken = await BoxWrapper.getInstance().then((box) => box.get(BoxKeys.ACCESS_TOKEN)).catchError(print);

    if (accessToken == null) {
      accessToken = await _accessTokenStrategyBinder(accessTokenUrl: accessTokenUrl);
    }

    return accessToken;
  }

  static Future<String> _accessTokenStrategyBinder({@required String accessTokenUrl}) async {
    return await BoxWrapper.getInstance().then((box) async {
      if (box.get(BoxKeys.ACCESS_TOKEN_STRATEGY) == AccessTokenStrategy.GET) {
        return await _httpGetAccessTokenStrategy(accessTokenUrl: accessTokenUrl);
      } else {
        throw(_UNDEFINED_ACCESS_TOKEN_STRATEGY);
      }
    });
  }

  static Future<String> _httpGetAccessTokenStrategy({@required String accessTokenUrl}) async {
    final headers = await getHeaders();
    final tokenResponse = await Dio().get(accessTokenUrl, options: Options(headers: headers));
    return tokenResponse.data;
  }

  static Future<void> persistAccessToken({@required String accessToken}) async {
    await BoxWrapper.getInstance().then((box) => box.put(BoxKeys.ACCESS_TOKEN, accessToken));
  }

  static Future<void> _setHeaders({@required Map<String, dynamic> headers}) async {
    await BoxWrapper.getInstance().then((box) => box.put(BoxKeys.HEADERS, headers));
  }

  static Future<Map<String, dynamic>> getHeaders() async {
    // typecast to Map<String, dynamic>, box.get isn't type safe
    final Map<String, dynamic> headers = await BoxWrapper.getInstance().then((box) => box.get(BoxKeys.HEADERS));
    return headers;
  }

  static Future<String> getFcmToken() async {
    return await _fcmTokenStrategyBinder();
  }

  static Future<String> _fcmTokenStrategyBinder() async {
    return await BoxWrapper.getInstance().then((box) {
      if (box.get(BoxKeys.FCM_TOKEN_STRATEGY) == FcmTokenStrategy.FIREBASE_MESSAGING) {
        return _fcmTokenStrategy();
      } else {
        throw(_UNDEFINED_FCM_TOKEN_STRATEGY);
      }
    });
  }

  static Future<String> _fcmTokenStrategy() {
    return FirebaseMessaging().getToken();
  }
}