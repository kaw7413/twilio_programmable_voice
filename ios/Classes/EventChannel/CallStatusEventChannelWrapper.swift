import Foundation
import Flutter

public class CallStatusEventChannelWrapper: BaseEventChannel {
	// TODO: remove
	public func testSend(data: [String: String]) {
		print("testSend called")
		self.send(data: data)
	}

	public func sendCallInvite(callInvite: [String: String]) {
		print("sendCallInvite called")
		self.send(data: callInvite)
	}

	public func sendCancelledCallInvite(cancelledCallInvite: [String: String]) {
		print("sendCancelledCallInvite called")
		self.send(data: cancelledCallInvite)
	}

	public func sendCallConnect(call: [String: Any]) {
		print("sendCallConnect called")
		self.send(data: call)
	}

	public func sendCallDisconnect(call: [String: Any]) {
		print("sendCallDisconnect called")
		self.send(data: call)
	}

	public func sendCallConnectFailure(call: [String: Any]) {
		print("sendCallConnectFailure called")
		self.send(data: call)
	}

	public func sendCallRinging(call: [String: Any]) {
		print("sendCallRinging called")
		self.send(data: call)
	}

	public func sendCallQualityWarningsChanged(call: [String: Any]) {
		print("sendCallQualityWarningsChanged called")
		self.send(data: call)
	}

	public func sendCallReconnecting(call: [String: Any]) {
		print("sendCallReconnecting called")
		self.send(data: call)
	}

	public func sendCallReconnect(call: [String: Any]) {
		print("sendCallReconnect called")
		self.send(data: call)
	}
}
