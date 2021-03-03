import Foundation
import TwilioVoice

/**
	Responsible of holding calls states and making API calls to TwilioVoice.
	
	It should only be instanciated once.
*/
public class TwilioProgrammableVoice: NSObject {
	// Used to create singleton
	static let sharedInstance = TwilioProgrammableVoice()

	// @TODO: supress this delegate in favor of a cleaner thing.
	// It forces us to add a bad (!) in every call to say : hey, it's initialized bro !
	// AKA unsafelyUnwrap
	var twilioVoiceDelegate: TwilioVoiceDelegate?

	var callKitDelegate = CallKitDelegate()
	let tokenManager = TokenManager()
	var _result: FlutterResult?
	let kClientList = "TwilioContactList"
	var clients: [String: String]!
	var identity = "alice"
	var callTo: String = "error"
	var defaultCaller = "Unknown Caller"
	var callArgs: [String: AnyObject] = [String: AnyObject]()
	var audioDevice: DefaultAudioDevice = DefaultAudioDevice()

	func makeCall(to: String) {
		print("makeCall called")
		if self.twilioVoiceDelegate!.call != nil && self.twilioVoiceDelegate!.call?.state == .connected {
			print("in first if")
			self.twilioVoiceDelegate!.userInitiatedDisconnect = true
			self.callKitDelegate.performEndCallAction(uuid: self.twilioVoiceDelegate!.call!.uuid!)
		} else {
			print("in else")
			let uuid = UUID()
			self.callKitDelegate.performStartCallAction(uuid: uuid, handle: to)
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
}
