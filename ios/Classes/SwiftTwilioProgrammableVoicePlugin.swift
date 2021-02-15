import Flutter
import UIKit
import TwilioVoice

// This class is the entrypoint, it valid the data and delegate the work to other class
public class SwiftTwilioProgrammableVoicePlugin: NSObject, FlutterPlugin {
	private var twilioProgrammableVoice : TwilioProgrammableVoice;
	
	init(messenger: FlutterBinaryMessenger) {
		twilioProgrammableVoice = TwilioProgrammableVoice(messenger: messenger);
		TwilioVoiceSDK.setLogLevel(TwilioVoiceSDK.LogLevel.all, module: TwilioVoiceSDK.LogModule.core);
		TwilioVoiceSDK.setLogLevel(TwilioVoiceSDK.LogLevel.all, module: TwilioVoiceSDK.LogModule.platform);
		TwilioVoiceSDK.setLogLevel(TwilioVoiceSDK.LogLevel.all, module: TwilioVoiceSDK.LogModule.signaling);
		TwilioVoiceSDK.setLogLevel(TwilioVoiceSDK.LogLevel.all, module: TwilioVoiceSDK.LogModule.webRTC);

		super.init();
	}
    
  public static func register(with registrar: FlutterPluginRegistrar) {
		let messenger = registrar.messenger();
		let channel = FlutterMethodChannel(name: "twilio_programmable_voice", binaryMessenger: messenger);
		let instance = SwiftTwilioProgrammableVoicePlugin(messenger: messenger);
		registrar.addMethodCallDelegate(instance, channel: channel);
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    let args = call.arguments as? Dictionary<String, Any>
    
		if (call.method == "registerVoice") {
			registerVoice(args: args, result: result);
		} else if (call.method == "makeCall") {
			makeCall(args: args, result: result);
		} else if (call.method == "handleMessage") {
			handleMessage(args: args, result: result)
		} else if (call.method == "answer") {
			answer(result: result);
		} else if (call.method == "reject") {
			reject(result: result);
		} else if (call.method == "testEventChannel") {
			print("call.method == testEventChannel");
			// TODO: remove this when eventChannel works
			testEventChannel(args: args, result: result)
		} else {
        result(FlutterMethodNotImplemented);
    }
  }
    
	private func registerVoice(args: Dictionary<String, Any>?, result: @escaping FlutterResult) {
		guard args != nil, let accessToken = args!["accessToken"] as? String, let deviceToken = args!["fcmToken"] as? String else {
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
	
	private func handleMessage(args: Dictionary<String, Any>?, result: @escaping FlutterResult) {
		guard args != nil, let data = args!["messageData"] as? Dictionary<String, String> else {
			result(FlutterError(code: PluginExceptionRessource.handleMessageArgsErrorCode, message: PluginExceptionRessource.handleMessageArgsErrorMessage, details: args))
				return;
		}
		
		result(true);
//		twilioProgrammableVoice.handleMessage();
 	}
	
	private func answer(result: FlutterResult) {
		// TODO:
		// get the current callInvite stock in twilioProgrammableVoice class
		// callInvite: CallInvite = twilioProgrammableVoice.getCurrentCallInvite();
		// then accept the call
		//callInvite.accept();
		result(true);
	}
	
	private func reject(result: FlutterResult) {
		// TODO:
		// get current callInvite and current call
		// callInvite: CallInvite = twilioProgrammableVoice.getCurrentCallInvite();
		// call: Call = twilioProgrammableVoice.getCurrentCall();
		// then check nil, if not nil reject it ex:
		// if (callInvite != nil) {
		// 	callInvite.reject(..)
		// }
		// same with call
		result(nil);
	}
	
	private func testEventChannel(args: Dictionary<String, Any>?, result: FlutterResult) {
		print("testEventChannel called");
		
		guard args != nil, let data = args!["data"] as? Dictionary<String, String> else {
			result(FlutterError(code: PluginExceptionRessource.handleMessageArgsErrorCode, message: PluginExceptionRessource.handleMessageArgsErrorMessage, details: args))
				return;
		}
		
		twilioProgrammableVoice.testEventChannel(data: data);
	}
}
