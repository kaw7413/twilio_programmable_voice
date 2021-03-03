import Foundation
import CallKit
import AVFoundation

class CallKitListener: NSObject, CXProviderDelegate {
	public func providerDidReset(_ provider: CXProvider) {
		TwilioProgrammableVoice.sharedInstance.audioDevice.isEnabled = false
	}

	public func providerDidBegin(_ provider: CXProvider) {
		print("providerDidBegin called")
	}

	public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
		print("Activate audio session")
		TwilioProgrammableVoice.sharedInstance.audioDevice.isEnabled = true
	}

	public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
		print("Deactivate audio session")
		TwilioProgrammableVoice.sharedInstance.audioDevice.isEnabled = false
	}

	public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
		print("provider timedOutPerforming called")
	}

	public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
		print("provider called CXStartCallAction")
		provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())

		TwilioProgrammableVoice.sharedInstance.performVoiceCall(uuid: action.callUUID, client: "") { (success) in
			print("in performVoiceCall cb")
				if success {
					print("success case")
						provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
				} else {
					print("not success case")
				}
		}

		action.fulfill()
	}

	public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		print("answer call")
		TwilioProgrammableVoice.sharedInstance.performAnswerVoiceCall(uuid: action.callUUID) { (success) in
			if success {
				print("success")
			} else {
				print("failure")
			}
		}

		action.fulfill()
	}

	public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		print("end call")
		if TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.callInvite != nil {
			TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.callInvite?.reject()
			TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.callInvite = nil
		} else if let call = TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.call {
				call.disconnect()
		}

		action.fulfill()
	}

	public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
		if let call = TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.call {
			call.isOnHold = action.isOnHold
			action.fulfill()
		} else {
			action.fail()
		}
	}

	public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
		if let call = TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!.call {
				call.isMuted = action.isMuted
				action.fulfill()
		} else {
				action.fail()
		}
	}
}
