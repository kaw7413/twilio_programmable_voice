import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class TwilioProgrammableVoice {
  static final MethodChannel _channel =
      const MethodChannel('twilio_programmable_voice')..setMethodCallHandler(_handleMethod);

  static List<void Function(Object)> onCallStatusCallbacks = <void Function(Object)>[];

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
    return _channel.invokeMethod('registerVoice', {"accessToken": accessToken, "fcmToken": fcmToken});
  }

  /// Add a listener to call status
  static void addCallStatusListener(void Function(Object) callback) {
    onCallStatusCallbacks.add(callback);
  }

  /// Add a previously registered listener
  static void removeCallStatusListener(void Function(Object) callback) {
    onCallStatusCallbacks.remove(callback);
  }

  /// Handle Fcm Message and delegate to Twilio
  static Future<String> handleMessage(Map<String, String> data) {
    return _channel.invokeMethod('handleMessage', {"messageData": data});
  }

  static Future<dynamic> _handleMethod(MethodCall call) async {
    switch (call.method) {
      case 'onCallStatusCallback':
        for (final callStatusCallback in onCallStatusCallbacks) {
          callStatusCallback(call.arguments);
        }
        break;
      default:
        throw ('method not defined');
    }
  }

  // Platform specifics
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
