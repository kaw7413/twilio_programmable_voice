import Foundation
import Flutter
import UIKit
import TwilioVoice

// this class is a TwilioVoiceSdk wrapper
internal class TwilioProgrammableVoice: NSObject, CallDelegate, NotificationDelegate {
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
			} else {
				result(true);
			}
		}
  }
	
	internal func makeCall(accessToken: String, from: String, to: String, result: FlutterResult) {
		// this doesn't work, no callback call,
		// BuiltInNSIsAvailable: Not supported on this platform and
		// BuiltInAECIsAvailable: Not supported on this platform
		let connectionOptions = ConnectOptions(accessToken: accessToken) { (builder) in
			builder.params = ["To": to, "From": from];
		}

		// let call = TwilioVoiceSDK.connect(options: connectionOptions, delegate: twilioVoiceCallListener);
		// set self as delegate for debuguing purpose but it might be not clean
		let call = TwilioVoiceSDK.connect(options: connectionOptions, delegate: self);

		print("this is the returned call object : ", call, call.state);
		result(true);
	}
	
	internal func handleMessage(data: Dictionary<String, String>, result: FlutterResult) {
		let isValid = TwilioVoiceSDK.handleNotification(data, delegate: self, delegateQueue: nil);
		
		if (isValid) {
			result(isValid);
		} else {
			result(FlutterError(code: PluginExceptionRessource.handleMessageErrorCode,
			message: PluginExceptionRessource.handleMessageErrorMessage,
			details: nil));
		}
	}
	
	func callInviteReceived(callInvite: CallInvite) {
		print("callInviteReceived called", callInvite);
	}
	
	func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
		print("cancelledCallInviteReceived called", cancelledCallInviteReceived);
	}
	
	func callDidConnect(call: Call) {
		print("callDidConnect cb called", call);
	}
	
	func callDidFailToConnect(call: Call, error: Error) {
		print("callDidFailToConnect cb called", call);
	}
	
	func callDidDisconnect(call: Call, error: Error?) {
		print("callDidDisconnect cb called", call);
	}
}
