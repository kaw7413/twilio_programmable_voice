import Foundation
import TwilioVoice
import Flutter
import CallKit

/**
	Responsible of holding calls states and making API calls to TwilioVoice.
	
	It should only be instanciated once, and only when flutter is ready to go !.
*/
public class TwilioProgrammableVoice: NSObject {
	// Used to create singleton
	static let sharedInstance = TwilioProgrammableVoice()

	// @TODO: supress this delegate in favor of a cleaner thing.
	// It forces us to add a bad (!) in every call to say : hey, it's initialized bro !
	// AKA unsafelyUnwrap
	var twilioVoiceDelegate: TwilioVoiceDelegate?

	// CallKit
	var callKitProvider: CXProvider
	let callKitCallController = CXCallController()
	let callKitListener = CallKitListener()

	let tokenManager = TokenManager()
	let kClientList = "TwilioContactList"
	var clients: [String: String]!
	var identity = "alice"
	var callTo: String = "error"
	var defaultCaller = "Unknown Caller"
	var callArgs: [String: AnyObject] = [String: AnyObject]()
	let audioDevice = DefaultAudioDevice()

	override init () {
		// Initiate call kit
		let configuration = CXProviderConfiguration(localizedName: SwiftTwilioProgrammableVoicePlugin.appName)
		callKitProvider = CXProvider(configuration: configuration)

		if let callKitIcon = UIImage(named: "logo_white") {
				configuration.iconTemplateImageData = callKitIcon.pngData()
		}

		super.init()

		callKitProvider.setDelegate(self.callKitListener, queue: nil)
	}

	deinit {
		callKitProvider.invalidate()
	}

	func makeCall(to: String, result: @escaping FlutterResult) {
		print("makeCall to", to)
		if self.twilioVoiceDelegate!.call != nil && self.twilioVoiceDelegate!.call?.state == .connected {
			self.twilioVoiceDelegate!.userInitiatedDisconnect = true
			self.performEndCallAction(uuid: self.twilioVoiceDelegate!.call!.uuid!)
		} else {
			// Probably not the right place for such an assignment
			TwilioVoice.audioDevice = audioDevice
			let uuid = UUID()
			print("UUID : ", uuid)
			self.performStartCallAction(uuid: uuid, handle: to) { (success) in
				result(success);
			}
		}
	}

	func toggleAudioRoute(toSpeaker: Bool) {
		// The mode set by the Voice SDK is "VoiceChat" so the default audio route is the built-in receiver. Use port override to switch the route.
		audioDevice.block = {
			DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
			do {
				if toSpeaker {
					try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
				} else {
					try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
				}
			} catch {
				print("switching audio output failed")
			}
		}
		audioDevice.block()
	}

	func performVoiceCall(uuid: UUID, client: String?, completionHandler: @escaping (Bool) -> Swift.Void) {
		guard let token = self.tokenManager.accessToken else {
			completionHandler(false)
			return
		}

		let connectOptions: ConnectOptions = ConnectOptions(accessToken: token) { (builder) in
			builder.params = ["To": self.callTo]
			for (key, value) in self.callArgs {
				// Only add from and to parameters, ignore the rest.
				if key != "to" && key != "from" {
					builder.params[key] = "\(value)"
				}
			}
			builder.uuid = uuid
		}
		print("CALLING")
		let theCall = TwilioVoice.connect(options: connectOptions, delegate: self.twilioVoiceDelegate!)
		self.twilioVoiceDelegate!.call = theCall
		self.twilioVoiceDelegate!.callCompletionCallback = completionHandler
	}

	func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Swift.Void) {
		if let ci = self.twilioVoiceDelegate!.callInvite {
			let acceptOptions: AcceptOptions = AcceptOptions(callInvite: ci) { (builder) in
				builder.uuid = ci.uuid
			}

			let theCall = ci.accept(options: acceptOptions, delegate: self.twilioVoiceDelegate!)
			self.twilioVoiceDelegate!.call = theCall
			self.twilioVoiceDelegate!.callCompletionCallback = completionHandler
			self.twilioVoiceDelegate!.callInvite = nil

			guard #available(iOS 13, *) else {
				self.tokenManager.incomingPushHandled()
				return
			}
		}
	}

	func performStartCallAction(uuid: UUID, handle: String, completion: @escaping (Bool) -> ()) {
		print("performStartCallAction called")

		let callHandle = CXHandle(type: .generic, value: "my syper handle")
		let startCallAction = CXStartCallAction(call: uuid, handle: callHandle)
		let transaction = CXTransaction(action: startCallAction)

		callKitCallController.request(transaction) { error in
			print("In callKitCallController.request cb")

			if error != nil {
				print(error as Any)
				print("error in cb", error.debugDescription as Any)
				return
			}

			print("creating callUpdate")
			let callUpdate = CXCallUpdate()
			callUpdate.remoteHandle = callHandle

			// @TODO: Allow to rename number to a custom display
			callUpdate.localizedCallerName = handle
			callUpdate.supportsDTMF = false
			callUpdate.supportsHolding = true
			callUpdate.supportsGrouping = false
			callUpdate.supportsUngrouping = false
			callUpdate.hasVideo = false

			print("reporting call", uuid, callUpdate)

			// TODO: wtf.
			// self.callKitProvider.setDelegate(self, queue: nil)

			self.callKitProvider.reportCall(with: uuid, updated: callUpdate)
			
			completion(true);
		}
	}

	func performEndCallAction(uuid: UUID) {
		let endCallAction = CXEndCallAction(call: uuid)
		let transaction = CXTransaction(action: endCallAction)

		callKitCallController.request(transaction) { error in
			if let error = error {
				print("error", error as Any)
			}
		}
	}

	func reportIncomingCall(from: String, uuid: UUID) {
		let callHandle = CXHandle(type: .generic, value: from)

		let callUpdate = CXCallUpdate()
		callUpdate.remoteHandle = callHandle

		// @TODO: override from that would usually display unknown caller
		// with a custom value
		callUpdate.localizedCallerName = from
		callUpdate.supportsDTMF = true
		callUpdate.supportsHolding = true
		callUpdate.supportsGrouping = false
		callUpdate.supportsUngrouping = false
		callUpdate.hasVideo = false

		self.callKitProvider.reportNewIncomingCall(with: uuid, update: callUpdate) { error in
			if let error = error {
				print("error", error as Any)
			}
		}
	}
}
