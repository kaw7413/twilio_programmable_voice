import Foundation
import Flutter

public class CallStatusEventChannelWrapper: BaseEventChannel {
	// TODO: remove
	public func testSend(data: Dictionary<String, String>) {
		print("testSend called");
		self.send(data: data);
	}
	
	public func sendCallInvite(callInvite: Dictionary<String, String>) {
		print("sendCallInvite called");
		self.send(data: callInvite);
	}
	
	public func sendCancelledCallInvite(cancelledCallInvite: Dictionary<String, String>) {
		print("sendCancelledCallInvite called");
		self.send(data: cancelledCallInvite);
	}
	
	public func sendCallConnect(call: Dictionary<String, Any>) {
		print("sendCallConnect called");
		self.send(data: call);
	}
	
	public func sendCallDisconnect(call: Dictionary<String, Any>) {
		print("sendCallDisconnect called");
		self.send(data: call);
	}
	
	public func sendCallConnectFailure(call: Dictionary<String, Any>) {
		print("sendCallConnectFailure called");
		self.send(data: call)
	}
	
	public func sendCallRinging(call: Dictionary<String, Any>) {
		print("sendCallRinging called");
		self.send(data: call)
	}
	
	public func sendCallQualityWarningsChanged(call: Dictionary<String, Any>) {
		print("sendCallQualityWarningsChanged called");
		self.send(data: call)
	}
	
	public func sendCallReconnecting(call: Dictionary<String, Any>) {
		print("sendCallReconnecting called");
		self.send(data: call)
	}
	
	public func sendCallReconnect(call: Dictionary<String, Any>) {
		print("sendCallReconnect called");
		self.send(data: call)
	}
}
