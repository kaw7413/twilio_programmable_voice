import Flutter
import AVFoundation
import TwilioVoice
import CallKit

/**
	Responsible of making the connection between Dart (flutter) and iOS native calls.
*/
public class SwiftTwilioProgrammableVoicePlugin: NSObject, FlutterPlugin {
	// Used to create singleton
	static let sharedInstance = SwiftTwilioProgrammableVoicePlugin()

	var methodChannel: FlutterMethodChannel?

	// interract with TwilioVoice API and hold calls states.
	var twilioProgrammableVoice: TwilioProgrammableVoice!

	// Initializer
	override init() {
		super.init()
	}

	static var appName: String {
		get {
			return (Bundle.main.infoDictionary!["CFBundleName"] as? String) ?? "Define CFBundleName"
		}
	}

	// Create a new singleton instance of the plugin class
	public static func register(with registrar: FlutterPluginRegistrar) {
		SwiftTwilioProgrammableVoicePlugin.sharedInstance.onRegister(registrar)
	}

	// Map dart method/events calls/stream to a defined methods/listeners (self.handle here)
	public func onRegister(_ registrar: FlutterPluginRegistrar) {
		self.twilioProgrammableVoice = TwilioProgrammableVoice.sharedInstance

		methodChannel = FlutterMethodChannel(name: "twilio_programmable_voice", binaryMessenger: registrar.messenger())
		methodChannel?.setMethodCallHandler(self.handle)

		let eventChannel = FlutterEventChannel(name: "twilio_programmable_voice/call_status", binaryMessenger: registrar.messenger())
		self.twilioProgrammableVoice.twilioVoiceDelegate = TwilioVoiceDelegate(eventChannel: eventChannel)
	}

	public func handle(_ flutterCall: FlutterMethodCall, result: @escaping FlutterResult) {
		let args: [String: AnyObject] = flutterCall.arguments as! [String: AnyObject]

		if flutterCall.method == "registerVoice" {
			guard let token = args["accessToken"] as? String else {return}
			self.twilioProgrammableVoice.tokenManager.accessToken = token
			if let deviceToken = self.twilioProgrammableVoice.tokenManager.deviceToken, let token = self.twilioProgrammableVoice.tokenManager.accessToken {
				TwilioVoice.register(accessToken: token, deviceToken: deviceToken) { (error) in
					if error != nil {
						result(FlutterError(code: "todo", message: "Problem while register", details: nil))
					} else {
						result(true)
					}
				}
			}
		} else if flutterCall.method == "makeCall" {
			print("handle -> makeCall")
			guard let callTo = args["to"] as? String else {return}
			guard let callFrom = args["from"] as? String else {return}

			if let accessToken = args["accessToken"] as? String {
				self.twilioProgrammableVoice.tokenManager.accessToken = accessToken
			}

			self.twilioProgrammableVoice.makeCall(to: callTo, from: callFrom, result: result)
		} else if flutterCall.method == "stopCall" {
			self.twilioProgrammableVoice.stopActiveCall(result: result)
		} else if flutterCall.method == "muteCall" {
			guard let setOn = args["setOn"] as? Bool else {return}

			self.twilioProgrammableVoice.muteActiveCall(setOn: setOn, result: result)
		} else if flutterCall.method == "toggleSpeaker" {
			guard let setOn = args["setOn"] as? Bool else {return}

			self.twilioProgrammableVoice.toggleAudioRoute(toSpeaker: setOn, result: result)
		} else if flutterCall.method == "isOnCall" {
			result(self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil)
			return
		} else if flutterCall.method == "sendDigits" {
			guard let digits = args["digits"] as? String else {return}
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil {
				self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.sendDigits(digits)
			}
		} else if flutterCall.method == "holdCall" {
			guard let setOn = args["setOn"] as? Bool else {return}

			self.twilioProgrammableVoice.muteActiveCall(setOn: setOn, result: result)
		} else if flutterCall.method == "answer" {
			result(true) /// do nothing
			return
		} else if flutterCall.method == "unregister" {
			guard let token = args["accessToken"] as? String else {return}
			guard let deviceToken = self.twilioProgrammableVoice.tokenManager.deviceToken else {
				return
			}

			self.twilioProgrammableVoice.tokenManager.unregisterTokens(token: token, deviceToken: deviceToken)
		} else if flutterCall.method == "hangUp"{
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil && self.twilioProgrammableVoice.twilioVoiceDelegate!.call?.state == .connected {
				self.twilioProgrammableVoice.twilioVoiceDelegate!.userInitiatedDisconnect = true
				self.twilioProgrammableVoice.performEndCallAction(uuid: self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.uuid!)
			}
		} else if flutterCall.method == "hasMicPermission" {
			result(true) /// do nothing
			return
		} else if flutterCall.method == "requestMicPermission"{
			result(true)/// do nothing
			return
		} else {
			result(FlutterMethodNotImplemented)
		}
	}

	// TODO remove this and the FlutterStreamHandler implementation
	// problem, I can't make call when I remove Notification.default.addObserver
	// No error, the CXStartCallAction event isn't trigger
	public func onListen(withArguments arguments: Any?,
											 eventSink: @escaping FlutterEventSink) -> FlutterError? {
		NotificationCenter.default.addObserver(
			self,
			selector: #selector(CallDelegate.callDidDisconnect),
			name: NSNotification.Name(rawValue: "PhoneCallEvent"),
			object: nil)

		return nil
	}

	public func onCancel(withArguments arguments: Any?) -> FlutterError? {
		NotificationCenter.default.removeObserver(self)
		return nil
	}
}
