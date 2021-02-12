import Foundation
import Flutter
import UIKit
import TwilioVoice

// this class is a TwilioVoiceSdk wrapper
internal class TwilioProgrammableVoice: NSObject {
    private var twilioVoiceCallListener: TwilioVoiceCallListener;

	override init() {
		twilioVoiceCallListener = TwilioVoiceCallListener();
		super.init();
	}

	internal func registerVoice(accessToken: String, deviceToken: Data, result: @escaping FlutterResult) {
		// TODO verify the invalid token case
		TwilioVoiceSDK.register(accessToken: accessToken, deviceToken: deviceToken) { (error) in
			if (error != nil) {
				result(FlutterError(code: PluginExceptionRessource.registerVoiceRegisterErrorCode,
				message: PluginExceptionRessource.registerVoiceRegisterErrorMessage,
				details: error))
			}
				result(true);
		}
  }
	
	internal func makeCall(accessToken: String, from: String, to: String, result: FlutterResult) {
		let connectionOptions = ConnectOptions(accessToken: accessToken) { (builder) in
			builder.params = ["to": to, "from": from];
		}

		TwilioVoiceSDK.connect(options: connectionOptions, delegate: twilioVoiceCallListener);
		result(true);
	}
}
