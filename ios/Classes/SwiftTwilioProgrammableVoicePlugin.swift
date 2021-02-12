import Flutter
import UIKit
import TwilioVoice

// This class is the entrypoint, it valid the data and delegate the work to other class
public class SwiftTwilioProgrammableVoicePlugin: NSObject, FlutterPlugin {
	private var twilioProgrammableVoice : TwilioProgrammableVoice;
	
	override init() {
		twilioProgrammableVoice = TwilioProgrammableVoice();
		super.init();
	}
    
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "twilio_programmable_voice", binaryMessenger: registrar.messenger())
    let instance = SwiftTwilioProgrammableVoicePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? Dictionary<String, Any>
    
		if (call.method == "registerVoice") {
			registerVoice(args: args, result: result);
		} else if (call.method == "makeCall") {
			makeCall(args: args, result: result)
		} else {
        result(FlutterMethodNotImplemented);
    }
  }
    
	private func registerVoice(args: Dictionary<String, Any>?, result: @escaping FlutterResult) {
		guard args != nil, let accessToken: String = args!["accessToken"] as? String, let deviceToken: String = args!["fcmToken"] as? String else {
			result(FlutterError(code: PluginExceptionRessource.registerVoiceArgsErrorCode, message: PluginExceptionRessource.registerVoiceArgsErrorMessage, details: args))
				return;
		}

		twilioProgrammableVoice.registerVoice(accessToken: accessToken, deviceToken: Data(deviceToken.utf8), result: result)
  }
	
	private func makeCall(args: Dictionary<String, Any>?, result: @escaping FlutterResult) {
		guard args != nil, let accessToken: String = args!["accessToken"] as? String, let from: String = args!["from"] as? String, let to: String = args!["to"] as? String else {
			result(FlutterError(code: PluginExceptionRessource.makeCallArgsErrorCode, message: PluginExceptionRessource.makeCallArgsErrorMessage, details: args))
				return;
		}

		twilioProgrammableVoice.makeCall(accessToken: accessToken, from: from, to: to, result: result);
	}
}



