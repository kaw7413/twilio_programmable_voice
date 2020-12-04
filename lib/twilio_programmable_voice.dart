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
    return _eventChannel.receiveBroadcastStream().map((data) {
      switch (data['type']) {
        case 'CallInvite':
          print("In CALL_INVITE");
          return CallInvite.from(data);

        case 'CancelledCallInvite':
          return CancelledCallInvite.from(data);

        case 'CallConnectFailure':
          return CallConnectFailure.from(data);

        case 'CallRinging':
          return CallRinging.from(data);

        case 'CallConnected':
          return CallConnected.from(data);

        case 'CallReconnecting':
          return CallReconnected.from(data);

        case 'CallReconnected':
          return CallReconnected.from(data);

        case 'CallDisconnected':
          return CallDisconnected.from(data);

        case 'CallQualityWarningChanged':
          return CallQualityWarningChanged.from(data);

        default:
          break;
      }

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

  // Platform specifics
  static Future<String> get platformVersion async {
    final String version =
        await _methodChannel.invokeMethod('getPlatformVersion');
    return version;
  }
}
