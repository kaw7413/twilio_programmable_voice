import Foundation
import Flutter

public class CallStatusEventChannelWrapper: BaseEventChannel {

	private func toJsonString(data: [String: Any]) -> String {
		var jsonString = "{"
		for attribute in data {
			jsonString += "\"\(attribute.key)\": \"\(attribute.value)\","
		}
		jsonString.removeLast()
		jsonString += "}"
		return jsonString;
	}

	public func sendCallInvite(callInvite: [String: Any]) {
		print("sendCallInvite called")
		self.send(data: toJsonString(data: callInvite))
	}

	public func sendCancelledCallInvite(cancelledCallInvite: [String: Any]) {
		print("sendCancelledCallInvite called")
		self.send(data: toJsonString(data: cancelledCallInvite))
	}

	public func sendCallConnect(call: [String: Any]) {
		print("sendCallConnect called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallDisconnect(call: [String: Any]) {
		print("sendCallDisconnect called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallConnectFailure(call: [String: Any]) {
		print("sendCallConnectFailure called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallRinging(call: [String: Any]) {
		print("sendCallRinging called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallQualityWarningsChanged(call: [String: Any]) {
		print("sendCallQualityWarningsChanged called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallReconnecting(call: [String: Any]) {
		print("sendCallReconnecting called")
		self.send(data: toJsonString(data: call))
	}

	public func sendCallReconnect(call: [String: Any]) {
		print("sendCallReconnect called")
		self.send(data: toJsonString(data: call))
	}
}
