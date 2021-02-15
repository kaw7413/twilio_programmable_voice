import Foundation

internal enum PluginExceptionRessource {
	internal static let registerVoiceArgsErrorCode = "1";
	internal static let registerVoiceArgsErrorMessage = "Arguments pass to the registerVoice method are not valid, accessToken and fcmToken should be defined";
	internal static let registerVoiceRegisterErrorCode = "2";
	internal static let registerVoiceRegisterErrorMessage = "Registration failed";
	internal static let makeCallArgsErrorCode = "3";
	internal static let makeCallArgsErrorMessage = "Arguments pass to the makeCall method are not valid, accessToken and from and to should be defined";
	internal static let handleMessageArgsErrorCode = "4";
	internal static let handleMessageArgsErrorMessage = "Arguments pass to the handleMessage method are not valid, messageData should be defined";
	internal static let handleMessageErrorCode = "5";
	internal static let handleMessageErrorMessage = "RMessage Data isn't a valid twilio message";
}
