//
//  TwilioProgrammableVoice.swift
//  twilio_programmable_voice
//
//  Created by Stardev on 23/02/2021.
//
import Foundation
import TwilioVoice

public class TwilioProgrammableVoice {
	public static let CALL_TEST = "CallTest";
	public static let CALL_INVITE = "CallInvite";
	public static let CANCELLED_CALL_INVITE = "CancelledCallInvite";
	public static let CALL_CONNECT_FAILURE = "CallConnectFailure";
	public static let CALL_RINGING = "CallRinging";
	public static let CALL_CONNECTED = "CallConnected";
	public static let CALL_RECONNECTING = "CallReconnecting";
	public static let CALL_RECONNECTED = "CallReconnected";
	public static let CALL_DISCONNECTED = "CallDisconnected";
	public static let CALL_QUALITY_WARNING_CHANGED = "CallQualityWarningChanged";
	public static let UNKNOW_FROM = "UNKNOW_FROM";
	public static let UNKNOW_TO = "UNKNOW_TO";
	
	public func registerVoice(accessToken: String, deviceToken: Data, result: @escaping FlutterResult) {
		TwilioVoice.register(accessToken: accessToken, deviceToken: deviceToken) { (error) in
			// TODO check when accessToken is expired
						if (error == nil) {
							print("Error == nil");
							result(true);
						} else {
							print("Error != nil", error as Any);
							// TODO add real code and message
							result(FlutterError(code: "PluginExceptionRessource.registerVoiceRegisterErrorCode",
							message: "PluginExceptionRessource.registerVoiceRegisterErrorMessage",
							details: nil))
						}
			}
	}
}
