import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'box_wrapper.dart';
import 'events.dart';

class TwilioProgrammableVoice {
  static final MethodChannel _methodChannel =
      const MethodChannel('twilio_programmable_voice');
  static final EventChannel _callStatusEventChannel =
      const EventChannel("twilio_programmable_voice/call_status");
  static final EventChannel _twilioRegistrationEventChannel =
      const EventChannel("twilio_programmable_voice/twilio_registration");

  static CallEvent _currentCallEvent;
  static Function _accessTokenStrategy;

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

  /// Delegate the registration to Twilio and start listening to call status.
  ///
  /// Throws an error if fail, the error returned by the Twilio Voice.register.
  static Future<void> registerVoice(Function accessTokenStrategy, String fcmToken) async {
    _accessTokenStrategy = accessTokenStrategy;
    String accessToken = await _getAccessToken();

    _twilioRegistrationEventChannel.receiveBroadcastStream().where((data) => data is bool).forEach((isRegistrationValid) async {
      if (!isRegistrationValid) {
        await BoxWrapper.getInstance().then((box) => box.put(BoxWrapper.key, null));
        accessToken = await _getAccessToken();
      }

      _persistAccessToken(accessToken);
    });

    return _methodChannel.invokeMethod(
        'registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});
  }

  static Future<String> _getAccessToken() async {
    String accessToken = await BoxWrapper.getInstance().then((box) => box.get(BoxWrapper.key));
    if (accessToken == null) {
      accessToken = await _accessTokenStrategy();
    }

    return accessToken;
  }

  static Future<void> _persistAccessToken(String accessToken) async {
    await BoxWrapper.getInstance().then((box) => box.put(BoxWrapper.key, accessToken));
  }

  /// Get the twilio registration stream
  // TODO make this work
  // can't map ?
  static Stream<bool> get twilioRegistrationStream {
    return _twilioRegistrationEventChannel.receiveBroadcastStream().where((data) => data is bool).map((isRegistrationValid) {
      return isRegistrationValid;
    });
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

  /// Answer the current call invite
  static Future<String> answer() {
    return _methodChannel.invokeMethod('answer');
  }

  /// Handle Fcm Message and delegate to Twilio
  static Future<bool> handleMessage(Map<String, String> data) {
    return _methodChannel.invokeMethod('handleMessage', {"messageData": data});
  }

  /// Reject the current call invite
  static Future<void> reject() {
    return _methodChannel.invokeMethod('reject');
  }

  /// Make a call
  ///
  /// [from] this device identity (or number)
  /// [to] the target identity (or number)
  static Future<bool> makeCall({String from, String to}) async {
    String accessToken = await _getAccessToken();
    return _methodChannel.invokeMethod('makeCall', {"from": from, "to": to, "accessToken": accessToken});
  }

  static bool _containsCall(dynamic value) {
    if (value is String) {
      return value.contains("Call");
    }
    return false;
  }

  static get getCall => _currentCallEvent;
}
