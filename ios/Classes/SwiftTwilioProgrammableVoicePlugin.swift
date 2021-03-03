import Flutter
import UIKit
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
		self.twilioProgrammableVoice = TwilioProgrammableVoice.sharedInstance;
		
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
			self.twilioProgrammableVoice.callArgs = args
			self.twilioProgrammableVoice.twilioVoiceDelegate!.callOutgoing = true
			if let accessToken = args["accessToken"] as? String {
				self.twilioProgrammableVoice.tokenManager.accessToken = accessToken
			}

			self.twilioProgrammableVoice.callTo = callTo
			self.twilioProgrammableVoice.identity = callFrom

			print("calling makeCall", "self.callTo", self.twilioProgrammableVoice.callTo, "identity", self.twilioProgrammableVoice.identity)
			self.twilioProgrammableVoice.makeCall(to: callTo)
		} else if flutterCall.method == "muteCall" {
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil {
				let muted = self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.isMuted
				self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.isMuted = !muted
			} else {
				let ferror: FlutterError = FlutterError(code: "MUTE_ERROR", message: "No call to be muted", details: nil)
				result(ferror)
			}
		} else if flutterCall.method == "toggleSpeaker" {
			guard let speakerIsOn = args["speakerIsOn"] as? Bool else {return}
			self.twilioProgrammableVoice.toggleAudioRoute(toSpeaker: speakerIsOn)
		} else if flutterCall.method == "isOnCall" {
			result(self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil)
			return
		} else if flutterCall.method == "sendDigits" {
			guard let digits = args["digits"] as? String else {return}
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil {
				self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.sendDigits(digits)
			}
		} else if flutterCall.method == "holdCall" {
			if self.twilioProgrammableVoice.twilioVoiceDelegate!.call != nil {
				let hold = self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.isOnHold
				self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.isOnHold = !hold
			}
		} else if flutterCall.method == "answer" {
			result(true) /// do nuthin
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
				self.twilioProgrammableVoice.callKitDelegate.performEndCallAction(uuid: self.twilioProgrammableVoice.twilioVoiceDelegate!.call!.uuid!)
			}
		} else if flutterCall.method == "registerClient"{
			// TODO bind that
			guard let clientId = args["id"] as? String, let clientName =  args["name"] as? String else {return}
			if self.twilioProgrammableVoice.clients[clientId] == nil || self.twilioProgrammableVoice.clients[clientId] != clientName {
				self.twilioProgrammableVoice.clients[clientId] = clientName
				UserDefaults.standard.set(self.twilioProgrammableVoice.clients, forKey: self.twilioProgrammableVoice.kClientList)
			}
		} else if flutterCall.method == "unregisterClient"{
			guard let clientId = args["id"] as? String else {return}
			self.twilioProgrammableVoice.clients.removeValue(forKey: clientId)
			UserDefaults.standard.set(self.twilioProgrammableVoice.clients, forKey: self.twilioProgrammableVoice.kClientList)
		} else if flutterCall.method == "defaultCaller"{
			guard let caller = args["defaultCaller"] as? String else {return}
			self.twilioProgrammableVoice.defaultCaller = caller
			if self.twilioProgrammableVoice.clients["defaultCaller"] == nil || self.twilioProgrammableVoice.clients["defaultCaller"] != self.twilioProgrammableVoice.defaultCaller {
				self.twilioProgrammableVoice.clients["defaultCaller"] = self.twilioProgrammableVoice.defaultCaller
				UserDefaults.standard.set(self.twilioProgrammableVoice.clients, forKey: self.twilioProgrammableVoice.kClientList)
			}
		} else if flutterCall.method == "hasMicPermission" {
			result(true) /// do nuthin
			return
		} else if flutterCall.method == "requestMicPermission"{
			result(true)/// do nuthin
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
