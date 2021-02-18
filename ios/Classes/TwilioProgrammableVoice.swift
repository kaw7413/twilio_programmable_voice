import Foundation
import Flutter
import UIKit
import TwilioVoice

// this class is a TwilioVoiceSdk wrapper
// TODO: test the call* callback
internal class TwilioProgrammableVoice: NSObject, CallDelegate, NotificationDelegate {
	private static let CALL_TEST = "CallTest";
	private static let CALL_INVITE = "CallInvite";
	private static let CANCELLED_CALL_INVITE = "CancelledCallInvite";
	private static let CALL_CONNECT_FAILURE = "CallConnectFailure";
	private static let CALL_RINGING = "CallRinging";
	private static let CALL_CONNECTED = "CallConnected";
	private static let CALL_RECONNECTING = "CallReconnecting";
	private static let CALL_RECONNECTED = "CallReconnected";
	private static let CALL_DISCONNECTED = "CallDisconnected";
	private static let CALL_QUALITY_WARNING_CHANGED = "CallQualityWarningChanged";
	private static let UNKNOW_FROM = "UNKNOW_FROM";
	private static let UNKNOW_TO = "UNKNOW_TO";

	
	private var twilioVoiceCallListener: TwilioVoiceCallListener;
	private let callStatusEventChannelWrapper: CallStatusEventChannelWrapper;
	
	// This is a an extra property which you will use internally
	private var _currentCallInvite: CallInvite?
	// the accecible one
	private var currentCallInvite: CallInvite? {
		get { return self._currentCallInvite }
		set {
			if (newValue == nil) {
				// we can't throw error here because we are in a setter, we might want to create a "classic" function as setter
				print("trying to set currentCallInvite to nil")
			} else {
				self._currentCallInvite = newValue;
				self.callStatusEventChannelWrapper.sendCallInvite(callInvite: getCallInvitePayload(callInvite: newValue!))
			}
		}
	};
	// This is a an extra property which you will use internally
	private var _currentCall: Call?
	private var currentCall: Call? {
		get { return self._currentCall }
		set { self._currentCall = newValue; }
	};
	// NOTE: we might want to use classic method getter/setter instead of this fancy Swift solution because we need to add another attribute for all private attribute
	
	init(messenger: FlutterBinaryMessenger) {
		let eventChannel = FlutterEventChannel(name: "twilio_programmable_voice/call_status", binaryMessenger: messenger);
		
		twilioVoiceCallListener = TwilioVoiceCallListener();
		callStatusEventChannelWrapper = CallStatusEventChannelWrapper(eventChannel: eventChannel);
		super.init();
	}

	internal func registerVoice(accessToken: String, deviceToken: Data, result: @escaping FlutterResult) {
		TwilioVoiceSDK.register(accessToken: accessToken, deviceToken: deviceToken) { (error) in
			if (error != nil) {
				result(FlutterError(code: PluginExceptionRessource.registerVoiceRegisterErrorCode,
				message: PluginExceptionRessource.registerVoiceRegisterErrorMessage,
				details: nil))
			} else {
				result(true);
			}
		}
  }
	
	internal func makeCall(accessToken: String, from: String, to: String, result: FlutterResult) {
		print("Inside TwilioPr..Voice makeCall");
		// this doesn't work, no callback call,
		// BuiltInNSIsAvailable: Not supported on this platform and
		// BuiltInAECIsAvailable: Not supported on this platform
		let connectOptions = ConnectOptions(accessToken: accessToken) { (builder) in
			builder.params = ["to": to, "from": from];
		}
		
		
//		this is in the VoiceExample app, I don't think it's necesary to specify the uuid but keep it here until it work
//		let connectOptions = ConnectOptions(accessToken: accessToken) { builder in
//			builder.params = ["to": to]
//			builder.uuid = UUID();
//		}
		
		print("ConnectionOptions : ", connectOptions);
		// TODO: delegate to twilioVoiceCallListener, currently delegating to self for debuggin purpose
		// let call = TwilioVoiceSDK.connect(options: connectionOptions, delegate: twilioVoiceCallListener);
		let call = TwilioVoiceSDK.connect(options: connectOptions, delegate: self);

		print("this is the returned call object : ", call, call.state.rawValue);
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
	
	// TODO: remove
	internal func testEventChannel(data: Dictionary<String, String>) {
		print("testEventChannel called inside TwilioObject");
		
		callStatusEventChannelWrapper.send(data: self.getCallPayloadTest(type: "tmp"));
		return;
	}
	
	func callInviteReceived(callInvite: CallInvite) {
		print("callInviteReceived called", callInvite);
		currentCallInvite = callInvite;
	}
	
	func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
		print("cancelledCallInviteReceived called", cancelledCallInviteReceived);
		callStatusEventChannelWrapper.sendCancelledCallInvite(cancelledCallInvite: getCancelledCallInvitePayload(cancelledCallInvite: cancelledCallInvite));
	}
	
	func callDidConnect(call: Call) {
		print("callDidConnect cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallConnect(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_CONNECTED));
	}
	
	func callDidFailToConnect(call: Call, error: Error) {
		print("callDidFailToConnect cb called", call);
		callStatusEventChannelWrapper.sendCallConnectFailure(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_CONNECT_FAILURE))
	}
	
	func callDidDisconnect(call: Call, error: Error?) {
		print("callDidDisconnect cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallDisconnect(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_DISCONNECTED))
	}
	
	func callDidStartRinging(call: Call) {
		print("callDidStartRinging cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallRinging(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_RINGING));
	}
	
	func callDidReceiveQualityWarnings(call: Call, currentWarnings: Set<NSNumber>, previousWarnings: Set<NSNumber>) {
		print("callDidStartRinging cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallQualityWarningsChanged(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_QUALITY_WARNING_CHANGED))
	}
	
	func callIsReconnecting(call: Call, error: Error) {
		print("callIsReconnecting cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallReconnecting(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_RECONNECTING))
	}
	
	func callDidReconnect(call: Call) {
		print("callDidReconnect cb called", call);
		currentCall = call;
		callStatusEventChannelWrapper.sendCallReconnect(call: getCallPayload(call: call, type: TwilioProgrammableVoice.CALL_RECONNECTED));
	}
	
	private func getCallPayloadTest(type: String) -> Dictionary<String, String> {
		return [
			"type": TwilioProgrammableVoice.CALL_TEST,
			"from": "from",
			"to": "to",
			"callSid": "callSid"
		]
	}
	
	private func getCallInvitePayload(callInvite: CallInvite) -> Dictionary<String, String> {
		return [
			"type": TwilioProgrammableVoice.CALL_INVITE,
			"from": callInvite.from ?? TwilioProgrammableVoice.UNKNOW_FROM,
			"to": callInvite.to,
			"callSid": callInvite.callSid
		]
	}

	private func getCancelledCallInvitePayload(cancelledCallInvite: CancelledCallInvite) -> Dictionary<String, String> {
		return [
			"type": TwilioProgrammableVoice.CANCELLED_CALL_INVITE,
			"from": cancelledCallInvite.from ?? TwilioProgrammableVoice.UNKNOW_FROM,
			"to": cancelledCallInvite.to,
			"callSid": cancelledCallInvite.callSid
		]
	}

	private func getCallPayload(call: Call , type: String) -> Dictionary<String, Any> {
		return [
			"type": type,
			"from": call.from ?? TwilioProgrammableVoice.UNKNOW_FROM,
			"to": call.to ?? TwilioProgrammableVoice.UNKNOW_TO,
			"sid": call.sid,
			"state": call.state.rawValue,
			"isMuted": call.isMuted,
			"isOnHold": call.isOnHold
		]
	}
}
