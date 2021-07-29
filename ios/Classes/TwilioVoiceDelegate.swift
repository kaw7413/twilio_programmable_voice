import Foundation
import TwilioVoice
import Flutter
import CallKit

class TwilioVoiceDelegate: NSObject, NotificationDelegate, CallDelegate {
	var callInvite: CallInvite?
	var call: Call?
	var callOutgoing: Bool = false
	var userInitiatedDisconnect: Bool = false
	// TODO find a better name
	var callCompletionCallback: ((Bool)->Swift.Void?)?
	private var callStatusEventChannelWrapper: CallStatusEventChannelWrapper

	init(eventChannel: FlutterEventChannel) {
		self.callStatusEventChannelWrapper = CallStatusEventChannelWrapper(eventChannel: eventChannel)
	}

	public func callInviteReceived(callInvite: CallInvite) {
		print("callInviteReceived called")
		var from: String = self.callInvite?.from ?? "Unknow Caller"
		from = from.replacingOccurrences(of: "client:", with: "")

		TwilioProgrammableVoice.sharedInstance.reportIncomingCall(from: from, uuid: callInvite.uuid)
		self.callInvite = callInvite

		self.callStatusEventChannelWrapper.sendCallInvite(callInvite: getCallInvitePayload(callInvite: callInvite))
	}

	public func cancelledCallInviteReceived(cancelledCallInvite: CancelledCallInvite, error: Error) {
		print("cancelledCallInviteReceived called")
			if self.callInvite == nil {
					return
			}

			if let ci = self.callInvite {
				TwilioProgrammableVoice.sharedInstance.performEndCallAction(uuid: ci.uuid)
			}

		self.callStatusEventChannelWrapper.sendCancelledCallInvite(cancelledCallInvite: getCancelledCallInvitePayload(cancelledCallInvite: cancelledCallInvite))
	}

	public func callDidStartRinging(call: Call) {
		print("callDidStartRinging called")
		callStatusEventChannelWrapper.sendCallRinging(call: getCallPayload(call: call, type: "CallRinging"))
	}

	public func callDidConnect(call: Call) {
		print("callDidConnect called")

		if let callKitCompletionCallback = self.callCompletionCallback {
					callKitCompletionCallback(true)
			}

		TwilioProgrammableVoice.sharedInstance.toggleAudioRoute(toSpeaker: false)
		callStatusEventChannelWrapper.sendCallConnect(call: getCallPayload(call: call, type: "CallConnected"))
	}

	public func call(call: Call, isReconnectingWithError error: Error) {
		print("isReconnectingWithError called")

		callStatusEventChannelWrapper.sendCallReconnecting(call: getCallPayload(call: call, type: "CallReconnecting"))
	}

	public func callDidReconnect(call: Call) {
		print("isReconnectingWithError callDidReconnect")

		callStatusEventChannelWrapper.sendCallReconnect(call: getCallPayload(call: call, type: "CallReconnected"))
	}

	public func callDidFailToConnect(call: Call, error: Error) {
		print("isReconnectingWithError callDidFailToConnect")
			if error.localizedDescription.contains("Access Token expired") {
				// TODO: re-generate an accessToken and re-place the call ?
				print("accessToken expired")
			}
		if let completion = self.callCompletionCallback {
					completion(false)
			}

		TwilioProgrammableVoice.sharedInstance.callKitProvider.reportCall(with: call.uuid!, endedAt: Date(), reason: CXCallEndedReason.failed)
		self.callDisconnected()
		// No callStatusEventWrapper method bind to this cb
	}

	public func callDidDisconnect(call: Call, error: Error?) {
		print("callDidDisconnect")

		var reason: CXCallEndedReason?

		if self.userInitiatedDisconnect {
			reason = CXCallEndedReason.remoteEnded
			if error != nil {
					reason = .failed
			}
		} else {
			reason = CXCallEndedReason.remoteEnded
		}

		TwilioProgrammableVoice.sharedInstance.callKitProvider.reportCall(with: call.uuid!, endedAt: Date(), reason: reason!)

		self.callDisconnected()

		callStatusEventChannelWrapper.sendCallDisconnect(call: getCallPayload(call: call, type: "CallDisconnected"))
	}

	private func callDisconnected() {
		print("callDisconnected")

			if self.call != nil {
				self.call = nil
			}
		if self.callInvite != nil {
			self.callInvite = nil
		}

			self.callOutgoing = false
			self.userInitiatedDisconnect = false
	}

	private func getCallInvitePayload(callInvite: CallInvite) -> [String: String] {
		return [
			"type": "CallInvite",
			"from": callInvite.from ?? "UNKNOWN_FROM",
			"to": callInvite.to,
			"callSid": callInvite.callSid
		]
	}

	private func getCancelledCallInvitePayload(cancelledCallInvite: CancelledCallInvite) -> [String: String] {
		return [
			"type": "CancelledCallInvite",
			"from": cancelledCallInvite.from ?? "UNKNOWN_FROM",
			"to": cancelledCallInvite.to,
			"callSid": cancelledCallInvite.callSid
		]
	}

	private func getCallPayload(call: Call, type: String) -> [String: Any] {
		return [
			"type": type,
			"from": call.from ?? "UNKNOWN_FROM",
			"to": call.to ?? "UNKNOWN_TO",
			"sid": call.sid,
			"state": call.state.rawValue,
			"isMuted": call.isMuted,
			"isOnHold": call.isOnHold
		]
	}
}
