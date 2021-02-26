import Flutter
import UIKit
import AVFoundation
import TwilioVoice
import CallKit

public class SwiftTwilioProgrammableVoicePlugin: NSObject, FlutterPlugin,  FlutterStreamHandler, AVAudioPlayerDelegate {
	// TODO make most of the attribute private
	// use to access instance in others plugin class
	static public var instance: SwiftTwilioProgrammableVoicePlugin?;
	let twilioVoiceDelegate: TwilioVoiceDelegate;
	let callKitDelegate = CallKitDelegate();
	let tokenManager = TokenManager();
	var _result: FlutterResult?
	// these attribute might not be at the right place
	let kClientList = "TwilioContactList"
	var clients: [String:String]!
	var identity = "alice"
	var callTo: String = "error"
	var defaultCaller = "Unknown Caller"
	var callArgs: Dictionary<String, AnyObject> = [String: AnyObject]()
	var audioDevice: DefaultAudioDevice = DefaultAudioDevice()
	
	static var appName: String {
		get {
			return (Bundle.main.infoDictionary!["CFBundleName"] as? String) ?? "Define CFBundleName"
		}
	}
	
	public override init() {
		clients = UserDefaults.standard.object(forKey: kClientList)  as? [String:String] ?? [:]
			
		let appDelegate = UIApplication.shared.delegate
		guard let controller = appDelegate?.window??.rootViewController as? FlutterViewController else {
				fatalError("rootViewController is not type FlutterViewController")
		}
		
		let registrar = controller.registrar(forPlugin: "twilio_programmable_voice")

		let eventChannel = FlutterEventChannel(name: "twilio_programmable_voice/call_status", binaryMessenger: registrar!.messenger())
		self.twilioVoiceDelegate = TwilioVoiceDelegate(eventChannel: eventChannel);
		super.init();
	}
		
		
	public static func register(with registrar: FlutterPluginRegistrar) {
		let instance = SwiftTwilioProgrammableVoicePlugin()
		SwiftTwilioProgrammableVoicePlugin.instance = instance
		let methodChannel = FlutterMethodChannel(name: "twilio_programmable_voice", binaryMessenger: registrar.messenger())
		registrar.addMethodCallDelegate(instance, channel: methodChannel)
	}
		
		public func handle(_ flutterCall: FlutterMethodCall, result: @escaping FlutterResult) {
				_result = result
				let args: Dictionary<String, AnyObject> = flutterCall.arguments as! Dictionary<String, AnyObject>;
				
				if flutterCall.method == "registerVoice" {
					guard let token = args["accessToken"] as? String else {return}
					self.tokenManager.accessToken = token
					if let deviceToken = self.tokenManager.deviceToken, let token = self.tokenManager.accessToken {
							TwilioVoice.register(accessToken: token, deviceToken: deviceToken) { (error) in
								if error != nil {
										result(FlutterError(code: "todo", message: "Problem while register", details: nil))
									}
									else {
										result(true);
									}
							}
					}
				} else if flutterCall.method == "makeCall" {
					print("handle -> makeCall");
						guard let callTo = args["to"] as? String else {return}
						guard let callFrom = args["from"] as? String else {return}
						self.callArgs = args
					  self.twilioVoiceDelegate.callOutgoing = true
						if let accessToken = args["accessToken"] as? String{
							self.tokenManager.accessToken = accessToken
						}
					
						self.callTo = callTo
						self.identity = callFrom
					
					print("calling makeCall", "self.callTo", self.callTo, "identity", self.identity);
						makeCall(to: callTo)
				}
				else if flutterCall.method == "muteCall"
				{
						if (self.twilioVoiceDelegate.call != nil) {
							let muted = self.twilioVoiceDelegate.call!.isMuted
							self.twilioVoiceDelegate.call!.isMuted = !muted
						} else {
								let ferror: FlutterError = FlutterError(code: "MUTE_ERROR", message: "No call to be muted", details: nil)
								_result!(ferror)
						}
				}
				else if flutterCall.method == "toggleSpeaker"
				{
						guard let speakerIsOn = args["speakerIsOn"] as? Bool else {return}
						toggleAudioRoute(toSpeaker: speakerIsOn)
				}
				else if flutterCall.method == "isOnCall"
				{
					result(self.twilioVoiceDelegate.call != nil);
						return;
				} else if flutterCall.method == "sendDigits"
				{
						guard let digits = args["digits"] as? String else {return}
						if (self.twilioVoiceDelegate.call != nil) {
								self.twilioVoiceDelegate.call!.sendDigits(digits);
						}
				} else if flutterCall.method == "holdCall" {
						if (self.twilioVoiceDelegate.call != nil) {
								
								let hold = self.twilioVoiceDelegate.call!.isOnHold
								self.twilioVoiceDelegate.call!.isOnHold = !hold
						}
				}
				else if flutterCall.method == "answer" {
					result(true) ///do nuthin
					return
				}
				else if flutterCall.method == "unregister" {
					guard let token = args["accessToken"] as? String else {return}
					guard let deviceToken = self.tokenManager.deviceToken else {
								return
						}
					
					self.tokenManager.unregisterTokens(token: token, deviceToken: deviceToken)
						
				}else if flutterCall.method == "hangUp"{
						if (self.twilioVoiceDelegate.call != nil && self.twilioVoiceDelegate.call?.state == .connected) {
							self.twilioVoiceDelegate.userInitiatedDisconnect = true
							self.callKitDelegate.performEndCallAction(uuid: self.twilioVoiceDelegate.call!.uuid!)
						}
				}else if flutterCall.method == "registerClient"{
					// TODO bind that
						guard let clientId = args["id"] as? String, let clientName =  args["name"] as? String else {return}
						if clients[clientId] == nil || clients[clientId] != clientName{
								clients[clientId] = clientName
								UserDefaults.standard.set(clients, forKey: kClientList)
						}
						
				}else if flutterCall.method == "unregisterClient"{
						guard let clientId = args["id"] as? String else {return}
						clients.removeValue(forKey: clientId)
						UserDefaults.standard.set(clients, forKey: kClientList)
						
				}else if flutterCall.method == "defaultCaller"{
						guard let caller = args["defaultCaller"] as? String else {return}
						defaultCaller = caller
						if(clients["defaultCaller"] == nil || clients["defaultCaller"] != defaultCaller){
								clients["defaultCaller"] = defaultCaller
								UserDefaults.standard.set(clients, forKey: kClientList)
						}
				} else if flutterCall.method == "hasMicPermission" {
						result(true) ///do nuthin
						return
				} else if flutterCall.method == "requestMicPermission"{
						result(true)///do nuthin
						return
				} else {
					result(FlutterMethodNotImplemented);
				}
		}
	
		func makeCall(to: String) {
			print("makeCall called");
				if (self.twilioVoiceDelegate.call != nil && self.twilioVoiceDelegate.call?.state == .connected) {
					print("in first if");
					self.twilioVoiceDelegate.userInitiatedDisconnect = true
					self.callKitDelegate.performEndCallAction(uuid: self.twilioVoiceDelegate.call!.uuid!)
				} else {
					print("in else");
					let uuid = UUID()
					self.callKitDelegate.performStartCallAction(uuid: uuid, handle: to)
				}
		}

		// MARK: AVAudioSession
		func toggleAudioRoute(toSpeaker: Bool) {
				// The mode set by the Voice SDK is "VoiceChat" so the default audio route is the built-in receiver. Use port override to switch the route.
			audioDevice.block = {
					DefaultAudioDevice.DefaultAVAudioSessionConfigurationBlock()
					do {
							if (toSpeaker) {
									try AVAudioSession.sharedInstance().overrideOutputAudioPort(.speaker)
							} else {
									try AVAudioSession.sharedInstance().overrideOutputAudioPort(.none)
							}
					} catch {
						print("switching audio output failed");
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
							if (key != "to" && key != "from") {
									builder.params[key] = "\(value)"
							}
					}
					builder.uuid = uuid
			}
			print("CALLING");
			let theCall = TwilioVoice.connect(options: connectOptions, delegate: self.twilioVoiceDelegate)
			self.twilioVoiceDelegate.call = theCall
			self.twilioVoiceDelegate.callCompletionCallback = completionHandler
		}
		
		func performAnswerVoiceCall(uuid: UUID, completionHandler: @escaping (Bool) -> Swift.Void) {
			if let ci = self.twilioVoiceDelegate.callInvite {
				let acceptOptions: AcceptOptions = AcceptOptions(callInvite: ci) { (builder) in
						builder.uuid = ci.uuid
				}

				let theCall = ci.accept(options: acceptOptions, delegate: self.twilioVoiceDelegate)
				self.twilioVoiceDelegate.call = theCall
				self.twilioVoiceDelegate.callCompletionCallback = completionHandler
				self.twilioVoiceDelegate.callInvite = nil
							
				guard #available(iOS 13, *) else {
					self.tokenManager.incomingPushHandled()
						return
				}
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

extension UIWindow {
		func topMostViewController() -> UIViewController? {
				guard let rootViewController = self.rootViewController else {
						return nil
				}
				return topViewController(for: rootViewController)
		}
		
		func topViewController(for rootViewController: UIViewController?) -> UIViewController? {
				guard let rootViewController = rootViewController else {
						return nil
				}
				guard let presentedViewController = rootViewController.presentedViewController else {
						return rootViewController
				}
				switch presentedViewController {
				case is UINavigationController:
						let navigationController = presentedViewController as! UINavigationController
						return topViewController(for: navigationController.viewControllers.last)
				case is UITabBarController:
						let tabBarController = presentedViewController as! UITabBarController
						return topViewController(for: tabBarController.selectedViewController)
				default:
						return topViewController(for: presentedViewController)
				}
		}
}
