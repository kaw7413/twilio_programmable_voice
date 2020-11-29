import 'dart:async';

import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

class TwilioProgrammableVoice {
  static const MethodChannel _channel =
      const MethodChannel('twilio_programmable_voice');

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

  /// Delegate the registration to Twilio.
  ///
  /// Throws an error if fail, the error returned by the Twilio Voice.register.
  static Future<void> registerVoice(String accessToken, String fcmToken) async {
    return _channel.invokeMethod('registerVoice');
  }

  // Platform specifics
  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
