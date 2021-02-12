import Foundation
import TwilioVoice

internal class TwilioVoiceCallListener: NSObject, CallDelegate {
	func callDidConnect(call: Call) {
		print("callDidConnect cb called");
		print(call);
	}
	
	func callDidFailToConnect(call: Call, error: Error) {
		print("callDidFailToConnect cb called");
		print(call);
	}
	
	func callDidDisconnect(call: Call, error: Error?) {
		print("callDidDisconnect cb called");
		print(call);
	}
}
