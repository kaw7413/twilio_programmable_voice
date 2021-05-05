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
		var args: [String: AnyObject] = [:];
		
		// we need this because sometimes arguments is nil and we unwrap a nil value, that throw an error and terminate the process :(
		if let flutterArgs = flutterCall.arguments {
			args = flutterArgs as! [String: AnyObject]
		}

		if flutterCall.method == "registerVoice" {
			guard let accessToken = args["accessToken"] as? String else {
				result(FlutterError(code: "MISSING-PARAMS", message: "Access token is missing", details: nil));
				return
			}
			
			self.twilioProgrammableVoice.registerVoice(accessToken: accessToken, result: result);
			
		} else if flutterCall.method == "makeCall" {
			
			guard let callTo = args["to"] as? String, let callFrom = args["from"] as? String else {
				result(FlutterError(code: "MISSING-PARAMS", message: "from or to parameters are/is missing", details: nil));
				return
			}
			
			guard let accessToken = args["accessToken"] as? String else {
				result(FlutterError(code: "MISSING-PARAMS", message: "accessToken is missing", details: nil));
				return
			}

			// Note: Not sure we want to store the accessToken since the token might be not valid
			// At this stage. Also the accessToken might not be registered yet.
			self.twilioProgrammableVoice.tokenManager.accessToken = accessToken
			
			self.twilioProgrammableVoice.makeCall(to: callTo, from: callFrom, result: result)
			
		} else if flutterCall.method == "stopCall" {
			
			self.twilioProgrammableVoice.stopActiveCall(result: result)
			
		} else if flutterCall.method == "muteCall" {
			
			guard let setOn = args["setOn"] as? Bool else {
				result(FlutterError(code: "MISSING-PARAMS", message: "setOn is missing", details: nil));
				return
			}

			self.twilioProgrammableVoice.muteActiveCall(setOn: setOn, result: result)
			
		} else if flutterCall.method == "toggleSpeaker" {
			
			guard let setOn = args["setOn"] as? Bool else {
				result(FlutterError(code: "MISSING-PARAMS", message: "setOn is missing", details: nil));
				return
			}
			
			self.twilioProgrammableVoice.toggleAudioRoute(toSpeaker: setOn, result: result)
			
		} else if flutterCall.method == "isOnCall" {
			
			result(self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil)
			
		} else if flutterCall.method == "sendDigits" {
			
			guard let digits = args["digits"] as? String else {
				result(FlutterError(code: "MISSING-PARAMS", message: "digits is missing", details: nil));
				return
			}
			
			guard self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil else {
				result(FlutterError(code: "PRECONDITION-FAILED", message: "cannot send digits, not on call", details: nil));
				return
			}

			self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.sendDigits(digits)
			
		} else if flutterCall.method == "holdCall" {
			
			guard let setOn = args["setOn"] as? Bool else {
				result(FlutterError(code: "MISSING-PARAMS", message: "setOn is missing", details: nil));
				return
			}

			self.twilioProgrammableVoice.muteActiveCall(setOn: setOn, result: result)
			
		} else if flutterCall.method == "getCurrentCall" {
			self.twilioProgrammableVoice.getCurrentCall(result: result);
		} else if flutterCall.method == "answer" {
			
			result(true) /// do nothing
			
		} else if flutterCall.method == "unregister" {
			
			guard let token = args["accessToken"] as? String else {
				result(FlutterError(code: "MISSING-PARAMS", message: "accessToken is missing", details: nil));
				return
			}
			
			guard let deviceToken = self.twilioProgrammableVoice.tokenManager.deviceToken else {
				result(FlutterError(code: "DTOKEN-MISSING", message: "Cannot find device token", details: nil));
				return
			}

			self.twilioProgrammableVoice.tokenManager.unregisterTokens(token: token, deviceToken: deviceToken)
			
		} else if flutterCall.method == "reject"{
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil && self.twilioProgrammableVoice.twilioVoiceDelegate!.call?.state == .connected {
				self.twilioProgrammableVoice.twilioVoiceDelegate!.userInitiatedDisconnect = true
				self.twilioProgrammableVoice.performEndCallAction(uuid: self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.uuid!)
			}
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
