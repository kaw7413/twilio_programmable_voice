import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'events.dart';

class TwilioProgrammableVoice {
  static final MethodChannel _methodChannel =
      const MethodChannel('twilio_programmable_voice');
  static final EventChannel _eventChannel =
      const EventChannel("twilio_programmable_voice/call_status");

  static List<void Function(Object)> onCallStatusCallbacks =
      <void Function(Object)>[];

  static CallEvent _currentCallEvent;

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
  static Future<void> registerVoice(String accessToken, String fcmToken) {
    return _methodChannel.invokeMethod(
        'registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});
  }

  /// Add a listener to call status
  static void addCallStatusListener(void Function(Object) callback) {
    onCallStatusCallbacks.add(callback);
  }

  /// Add a previously registered listener
  static void removeCallStatusListener(void Function(Object) callback) {
    onCallStatusCallbacks.remove(callback);
  }

  /// Get the incoming calls stream
  static Stream<dynamic> get callStatusStream {
    print("in STATUS_STREAM");
    CallEvent currentCallEvent;

    return _eventChannel.receiveBroadcastStream().map((data) {
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
      TwilioProgrammableVoice._currentCallEvent= currentCallEvent;
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
  static Future<bool> makeCall({String from, String to}) {
    return _methodChannel.invokeMethod('makeCall', {"from": from, "to": to});
  }

  // Platform specifics
  static Future<String> get platformVersion async {
    final String version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }

  static get getCall => _currentCallEvent;
}
