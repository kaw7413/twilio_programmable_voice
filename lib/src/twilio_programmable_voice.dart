import 'dart:async';

import 'package:dio/dio.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:uuid/uuid.dart';
import 'package:workmanager/workmanager.dart';
import 'package:meta/meta.dart';

import 'box_wrapper.dart';
import 'callback_dispatcher.dart';
import 'events.dart';

class TwilioProgrammableVoice {
  static const ACCESS_TOKEN_URL_IS_NULL = "You must provide a valid accessTokenUrl, null was provided";
  static const BG_UNIQUE_NAME = "registrationJob";
  static const BG_TASK_NAME = "twilio-registration";
  static const BG_TAG = "registration";
  static const BG_URL_DATA_KEY = "accessTokenUrl";
  static const BG_BACKOFF_POLICY_DELAY = Duration(seconds: 15);
  static const Duration SAFETY_DURATION = Duration(seconds: 15);
  static final MethodChannel _methodChannel =
      const MethodChannel('twilio_programmable_voice');
  static final EventChannel _callStatusEventChannel =
      const EventChannel("twilio_programmable_voice/call_status");

  static CallEvent _currentCallEvent;
  static String _accessTokenUrl;

  /// Must be the first function you call in the TwilioProgrammableVoice package
  ///
  /// This function will store the accessTokenUrl inside the class,
  /// init the background registration strategy and call registerVoice method
  static Future<bool> setUp({@required String accessTokenUrl}) async{
    _setAccessTokenUrl(accessTokenUrl);
    _setUpWorkmanager();
    final bool isRegistrationValid = await registerVoice(accessTokenUrl: accessTokenUrl);
    return isRegistrationValid;
  }

  /// Delegate the registration to Twilio and start listening to call status.
  /// You must call setUp method before because it will initialise the
  /// background registration strategy and store the accessTokenUrl inside
  /// the class
  ///
  /// Throws an error if fail, the error returned by the Twilio Voice.register.
  ///
  /// Returns a bool value representing the registration status
  ///
  /// [accessTokenUrl] an url which returns a valid accessToken when access
  /// by HTTP GET method
  static Future<bool> registerVoice({@required String accessTokenUrl}) async {
    bool isRegistrationValid;
    String accessToken = await _getAccessToken(accessTokenUrl: accessTokenUrl);
    String fcmToken = await _getFcmToken();
    try {
      isRegistrationValid = await _methodChannel.invokeMethod(
          'registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});

      _persistAccessToken(accessToken: accessToken);

      launchJobInBg(accessTokenUrl : accessTokenUrl, accessToken: accessToken);
    } catch (err) {
      isRegistrationValid = false;
      await BoxWrapper.getInstance().then((box) => box.delete(BoxWrapper.KEY));
      registerVoice(accessTokenUrl: accessTokenUrl);
    }

    return isRegistrationValid;
  }

  /// Make a call
  ///
  /// [from] this device identity (or number)
  /// [to] the target identity (or number)
  static Future<bool> makeCall({@required String from, @required String to}) async {
    String accessToken = await _getAccessToken(accessTokenUrl: _accessTokenUrl);
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

  static Future<String> _getAccessToken({@required String accessTokenUrl}) async {
    String accessToken = await BoxWrapper.getInstance().then((box) => box.get(BoxWrapper.KEY)).catchError(print);

    if (accessToken == null) {
      accessToken = await _accessTokenStrategy(accessTokenUrl: accessTokenUrl);
    }

    return accessToken;
  }

  static Future<String> _accessTokenStrategy({@required String accessTokenUrl}) async {
    final tokenResponse =
    await Dio().get(accessTokenUrl);
    return tokenResponse.data;
  }

  static Future<void> _persistAccessToken({@required String accessToken}) async {
    await BoxWrapper.getInstance().then((box) => box.put(BoxWrapper.KEY, accessToken));
  }

  static Future<String> _getFcmToken() async {
    // Maybe persist the fcm token
    return await _fcmTokenStrategy();
  }

  static Future<String> _fcmTokenStrategy() {
    return FirebaseMessaging().getToken();
  }

  static void _setUpWorkmanager() {
    Workmanager.initialize(
        callbackDispatcher,
        isInDebugMode: true
    );
    Workmanager.cancelByTag(BG_TAG);
  }

  static Future<void> launchJobInBg(
      {@required String accessTokenUrl, @required String accessToken}) async {
    await Workmanager.registerOneOffTask(getUniqueName(), BG_TASK_NAME,
        tag: BG_TAG,
        constraints: Constraints(
            networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.linear,
        backoffPolicyDelay: BG_BACKOFF_POLICY_DELAY,
        inputData: {
          BG_URL_DATA_KEY: accessTokenUrl
        },
        initialDelay: _getDelayBeforeExec(accessToken: accessToken));
  }

  static Duration _getDelayBeforeExec({@required String accessToken}) {
    DateTime expirationDate = JwtDecoder.getExpirationDate(accessToken);
    Duration duration = expirationDate.difference(DateTime.now());

    return duration - SAFETY_DURATION;
  }

  static void _setAccessTokenUrl([String accessTokenUrl]) {
    if (accessTokenUrl == null) {
      throw(ACCESS_TOKEN_URL_IS_NULL);
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
    return BG_UNIQUE_NAME + Uuid().v1();
  }
}

