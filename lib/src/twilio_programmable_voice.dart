import 'dart:async';

import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:twilio_programmable_voice/src/token_manager.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'package:meta/meta.dart';

import 'callback_dispatcher.dart';
import 'box_utils.dart';
import 'events.dart';
import 'box_wrapper.dart';

class TwilioProgrammableVoice {
  static const _ACCESS_TOKEN_URL_IS_NULL = "You must provide a valid accessTokenUrl, null was provided";
  static const _BG_UNIQUE_NAME = "registrationJob";
  static const _BG_TASK_NAME = "twilio-registration";
  static const _BG_TAG = "registration";
  static const BG_URL_DATA_KEY = "accessTokenUrl";
  static const _BG_BACKOFF_POLICY_DELAY = Duration(seconds: 15);
  static const Duration _SAFETY_DURATION = Duration(seconds: 15);
  static CallEvent _currentCallEvent;
  static String _accessTokenUrl;

  static final MethodChannel _methodChannel =
      const MethodChannel('twilio_programmable_voice');
  static final EventChannel _callStatusEventChannel =
      const EventChannel("twilio_programmable_voice/call_status");

  /// Must be the first function you call in the TwilioProgrammableVoice package
  ///
  /// This function will store the accessTokenUrl inside the class,
  /// init the background registration strategy and call registerVoice method
  ///
  /// [accessTokenUrl] is the url that return the access token
  ///
  ///
  /// [tokenManagerConfig] an optional map where you can set defined the strategies you want to use to retrieve tokens
  ///
  /// [headers] optional headers, use by the GET access token strategy
  static Future<bool> setUp({@required String accessTokenUrl, Map<String, Object> tokenManagerConfig, Map<String, dynamic> headers}) async {
    _setAccessTokenUrl(accessTokenUrl);
    _setUpWorkmanager();
    _setUpTokenManager(tokenManagerConfig, headers);

    final bool isRegistrationValid = await registerVoice(accessTokenUrl: accessTokenUrl);
    return isRegistrationValid;
  }

  /// Delegate the registration to Twilio and start listening to call status.
  /// You must call setUp method before because it will initialise the
  /// background registration strategy and store the accessTokenUrl
  ///
  /// Throws an error if fail, the error returned by the Twilio Voice.register.
  ///
  /// Returns a bool value representing the registration status
  ///
  /// [accessTokenUrl] an url which returns a valid accessToken when access
  /// by HTTP GET method
  static Future<bool> registerVoice({@required String accessTokenUrl}) async {
    bool isRegistrationValid;
    String accessToken = await TokenManager.getAccessToken(accessTokenUrl: accessTokenUrl);
    String fcmToken = await TokenManager.getFcmToken();

    try {
      isRegistrationValid = await _methodChannel.invokeMethod(
          'registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});
      TokenManager.persistAccessToken(accessToken: accessToken);
      launchJobInBg(accessTokenUrl : accessTokenUrl, accessToken: accessToken);
    } catch (err) {
      isRegistrationValid = false;
      await BoxWrapper.getInstance().then((box) => box.delete(BoxKeys.ACCESS_TOKEN));
      registerVoice(accessTokenUrl: accessTokenUrl);
    }

    return isRegistrationValid;
  }

  /// Make a call
  ///
  /// [from] this device identity (or number)
  /// [to] the target identity (or number)
  static Future<bool> makeCall({@required String from, @required String to}) async {
    String accessToken = await TokenManager.getAccessToken(accessTokenUrl: _accessTokenUrl);
    return _methodChannel.invokeMethod('makeCall', {"from": from, "to": to, "accessToken": accessToken});
  }

  /// Answer the current call invite
  static Future<String> answer() {
    return _methodChannel.invokeMethod('answer');
  }

  /// Handle Fcm Message and delegate to Twilio
  static Future<bool> handleMessage({@required Map<String, String> data}) {
    return _methodChannel.invokeMethod('handleMessage', {"messageData": data});
  }

  /// Reject the current call invite
  static Future<void> reject() {
    return _methodChannel.invokeMethod('reject');
  }

  /// Request microphone permission on the platform
  ///
  /// Return the microphone [PermissionStatus] after trying to request permissions.
  static Future<PermissionStatus> requestMicrophonePermissions() async {
    final microphonePermissionStatus = await Permission.microphone.status;

    if (!microphonePermissionStatus.isGranted) {
      return await Permission.microphone.request();
    }

    return microphonePermissionStatus;
  }

  /// Get the incoming calls stream
  static Stream<CallEvent> get callStatusStream {
    CallEvent currentCallEvent;

    return _callStatusEventChannel.receiveBroadcastStream().where((data) => _containsCall(data['type'])).map((data) {
      switch (data['type']) {
        case 'CallInvite':
          currentCallEvent = CallInvite.from(data);
          break;

        case 'CancelledCallInvite':
          currentCallEvent = CancelledCallInvite.from(data);
          break;

        case 'CallConnectFailure':
          currentCallEvent = CallConnectFailure.from(data);
          break;

        case 'CallRinging':
          currentCallEvent = CallRinging.from(data);
          break;

        case 'CallConnected':
          currentCallEvent = CallConnected.from(data);
          break;

        case 'CallReconnecting':
          currentCallEvent = CallReconnected.from(data);
          break;

        case 'CallReconnected':
          currentCallEvent = CallReconnected.from(data);
          break;

        case 'CallDisconnected':
          currentCallEvent = CallDisconnected.from(data);
          break;

        case 'CallQualityWarningChanged':
          currentCallEvent = CallQualityWarningChanged.from(data);
          break;

        default:
          break;
      }

      _currentCallEvent = currentCallEvent;
      return currentCallEvent;
    });
  }

  static void _setUpWorkmanager() {
    Workmanager.initialize(
        callbackDispatcher,
        isInDebugMode: true
    );
    Workmanager.cancelByTag(_BG_TAG);
  }

  static Future<void> _setUpTokenManager(Map<String, String> tokenManagerConfig, Map<String, dynamic> headers) async {
    bool areStrategiesDefined = await TokenManager.areStrategiesDefined();
    if (tokenManagerConfig != null) {
      TokenManager.setUp(config: tokenManagerConfig);
    } else if (!areStrategiesDefined) {
      TokenManager.setUp(config: TokenManager.DEFAULT_CONFIG);
    }

    if (headers != null) {
      TokenManager.setHeaders(headers: headers);
    }
  }

  static Future<void> launchJobInBg(
      {@required String accessTokenUrl, @required String accessToken}) async {
    await Workmanager.registerOneOffTask(getUniqueName(), _BG_TASK_NAME,
        tag: _BG_TAG,
        constraints: Constraints(
            networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: _BG_BACKOFF_POLICY_DELAY,
        inputData: {
          BG_URL_DATA_KEY: accessTokenUrl
        },
        initialDelay: _getDelayBeforeExec(accessToken: accessToken));
  }

  static Duration _getDelayBeforeExec({@required String accessToken}) {
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    Duration duration = expirationDate.difference(DateTime.now());

    return duration - _SAFETY_DURATION;
  }

  static void _setAccessTokenUrl([String accessTokenUrl]) {
    if (accessTokenUrl == null) {
      throw(_ACCESS_TOKEN_URL_IS_NULL);
    }

    _accessTokenUrl = accessTokenUrl;
  }

  static bool _containsCall(dynamic value) {
    if (value is String) {
      return value.contains("Call");
    }
    return false;
  }

  static get getCall => _currentCallEvent;

  static String getUniqueName() {
    return _BG_UNIQUE_NAME + Uuid().v1();
  }
}

