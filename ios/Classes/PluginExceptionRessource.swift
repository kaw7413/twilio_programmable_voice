import Foundation

internal struct PluginExceptionRessource {
	internal static let registerVoiceArgsErrorCode = "1";
	internal static let registerVoiceArgsErrorMessage = "Arguments pass to the registerVoice method are not valid, accessToken and fcmToken should be defined";
	internal static let registerVoiceRegisterErrorCode = "2";
	internal static let registerVoiceRegisterErrorMessage = "Registration failed";
	internal static let makeCallArgsErrorCode = "3";
	internal static let makeCallArgsErrorMessage = "Arguments pass to the makeCall method are not valid, accessToken and from and to should be defined";
}
