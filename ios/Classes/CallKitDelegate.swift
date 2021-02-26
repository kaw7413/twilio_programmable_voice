import Foundation
import CallKit
import AVFoundation

class CallKitDelegate: NSObject, CXProviderDelegate {
	var callKitProvider: CXProvider
	var callKitCallController: CXCallController

	override init () {
		let configuration = CXProviderConfiguration(localizedName: SwiftTwilioProgrammableVoicePlugin.appName)
		callKitProvider = CXProvider(configuration: configuration)
		callKitCallController = CXCallController()
		super.init()
		
		callKitProvider.setDelegate(self, queue: nil)
		if let callKitIcon = UIImage(named: "logo_white") {
				configuration.iconTemplateImageData = callKitIcon.pngData()
		}
	}
	
	deinit {
// CallKit has an odd API contract where the developer must call invalidate or the CXProvider is leaked.
		callKitProvider.invalidate()
	}
	
	public func providerDidReset(_ provider: CXProvider) {
		SwiftTwilioProgrammableVoicePlugin.instance!.audioDevice.isEnabled = false
	}
	
	public func providerDidBegin(_ provider: CXProvider) {
		print("providerDidBegin called")
	}
	
	public func provider(_ provider: CXProvider, didActivate audioSession: AVAudioSession) {
		SwiftTwilioProgrammableVoicePlugin.instance!.audioDevice.isEnabled = true
	}
	
	public func provider(_ provider: CXProvider, didDeactivate audioSession: AVAudioSession) {
		SwiftTwilioProgrammableVoicePlugin.instance!.audioDevice.isEnabled = false
	}
	
	public func provider(_ provider: CXProvider, timedOutPerforming action: CXAction) {
		print("provider timedOutPerforming called")
	}
	
	public func provider(_ provider: CXProvider, perform action: CXStartCallAction) {
		print("provider called CXStartCallAction");
		provider.reportOutgoingCall(with: action.callUUID, startedConnectingAt: Date())
			
		SwiftTwilioProgrammableVoicePlugin.instance!.performVoiceCall(uuid: action.callUUID, client: "") { (success) in
			print("in performVoiceCall cb");
				if (success) {
					print("success case");
						provider.reportOutgoingCall(with: action.callUUID, connectedAt: Date())
				} else {
					print("not success case");
				}
		}
		
		action.fulfill()
	}
	
	public func provider(_ provider: CXProvider, perform action: CXAnswerCallAction) {
		SwiftTwilioProgrammableVoicePlugin.instance!.performAnswerVoiceCall(uuid: action.callUUID) { (success) in
			if success {
				print("success")
			} else {
				print("failure")
			}
		}
			
		action.fulfill()
	}
	
	public func provider(_ provider: CXProvider, perform action: CXEndCallAction) {
		if (SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.callInvite != nil) {
			SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.callInvite?.reject()
			SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.callInvite = nil
		} else if let call = SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.call {
				call.disconnect()
		}
		
		action.fulfill()
	}
	
	public func provider(_ provider: CXProvider, perform action: CXSetHeldCallAction) {
		if let call = SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.call {
			call.isOnHold = action.isOnHold
			action.fulfill()
		} else {
			action.fail()
		}
	}
	
	public func provider(_ provider: CXProvider, perform action: CXSetMutedCallAction) {
		if let call = SwiftTwilioProgrammableVoicePlugin.instance!.twilioVoiceDelegate.call {
				call.isMuted = action.isMuted
				action.fulfill()
		} else {
				action.fail()
		}
	}
	
	func performStartCallAction(uuid: UUID, handle: String) {
		print("performStartCallAction called");
			let callHandle = CXHandle(type: .generic, value: handle)
			let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
			let transaction = CXTransaction(action: startCallAction)
			
		callKitCallController.request(transaction)  { error in
				print("In callKitCallController.request cb");
				if error != nil {
						print("error in cb", error as Any);
							return
				}
					
				print("creating callUpdate");
				let callUpdate = CXCallUpdate()
				callUpdate.remoteHandle = callHandle
				callUpdate.localizedCallerName = SwiftTwilioProgrammableVoicePlugin.instance!.clients[handle] ?? SwiftTwilioProgrammableVoicePlugin.instance!.clients["defaultCaller"] ?? "self.defaultCaller"
				callUpdate.supportsDTMF = false
				callUpdate.supportsHolding = true
				callUpdate.supportsGrouping = false
				callUpdate.supportsUngrouping = false
				callUpdate.hasVideo = false
					
				print("reporting call", uuid, callUpdate);
				self.callKitProvider.reportCall(with: uuid, updated: callUpdate)
			}
	}
	
	func performEndCallAction(uuid: UUID) {
		let endCallAction = CXEndCallAction(call: uuid)
		let transaction = CXTransaction(action: endCallAction)
			
		callKitCallController.request(transaction) { error in
			if let error = error {
				print("error", error as Any);
			}
		}
	}
	
	func reportIncomingCall(from: String, uuid: UUID) {
		let callHandle = CXHandle(type: .generic, value: from)
		
		let callUpdate = CXCallUpdate()
		callUpdate.remoteHandle = callHandle
		callUpdate.localizedCallerName = SwiftTwilioProgrammableVoicePlugin.instance!.clients[from] ?? SwiftTwilioProgrammableVoicePlugin.instance!.clients["defaultCaller"] ?? SwiftTwilioProgrammableVoicePlugin.instance!.defaultCaller
		callUpdate.supportsDTMF = true
		callUpdate.supportsHolding = true
		callUpdate.supportsGrouping = false
		callUpdate.supportsUngrouping = false
		callUpdate.hasVideo = false
		
		self.callKitProvider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
			if let error = error {
				print("error", error as Any);
			}
		}
	}
}
