import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:meta/meta.dart';

import 'box_utils.dart';
// TODO make a folder service with proper export
import 'box_service.dart';
import 'events.dart';
import 'token_service.dart';
import 'workmanager_wrapper.dart';
import 'injector.dart';

abstract class TwilioProgrammableVoice {
  static const _ACCESS_TOKEN_URL_IS_NULL = "You must provide a valid accessTokenUrl, null was provided";
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
  /// [tokenManagerStrategies] an optional map where you can set defined the strategies you want to use to retrieve tokens
  ///
  /// [headers] optional headers, use by the GET access token strategy
  static Future<bool> setUp({@required String accessTokenUrl, Map<String, Object> tokenManagerStrategies, Map<String, dynamic> headers}) async {
    _setAccessTokenUrl(accessTokenUrl);
    WorkmanagerWrapper.setUpWorkmanager();
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
    bool isRegistrationValid = true;
    String accessToken = await getService<TokenService>().getAccessToken(accessTokenUrl: accessTokenUrl);
    String fcmToken = await getService<TokenService>().getFcmToken();

    try {
      await _methodChannel.invokeMethod(
          'registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});
      getService<TokenService>().persistAccessToken(accessToken: accessToken);
      WorkmanagerWrapper.launchJobInBg(accessTokenUrl : accessTokenUrl, accessToken: accessToken);
    } catch (err) {
      isRegistrationValid = false;
      await getService<BoxService>().getBox().then((box) => box.delete(BoxKeys.ACCESS_TOKEN));
      registerVoice(accessTokenUrl: accessTokenUrl);
    }

    return isRegistrationValid;
  }

  /// Make a call
  ///
  /// [from] this device identity (or number)
  /// [to] the target identity (or number)
  static Future<bool> makeCall({@required String from, @required String to}) async {
    String accessToken = await getService<TokenService>().getAccessToken(accessTokenUrl: _accessTokenUrl);
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
}

