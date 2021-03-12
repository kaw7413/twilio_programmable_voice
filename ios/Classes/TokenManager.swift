import Foundation
import PushKit
import TwilioVoice
// To access to UIDevice version
import UIKit

class TokenManager: NSObject, PKPushRegistryDelegate {
	var voipRegistry: PKPushRegistry
	let kCachedDeviceToken = "CachedDeviceToken"
	var deviceToken: Data? {
			get {UserDefaults.standard.data(forKey: kCachedDeviceToken)}
			set {UserDefaults.standard.setValue(newValue, forKey: kCachedDeviceToken)}
	}
	var accessToken: String?
	var incomingPushCompletionCallback: (()->Swift.Void?)?

	public override init() {
		voipRegistry = PKPushRegistry.init(queue: DispatchQueue.main)
		super.init()

		voipRegistry.delegate = self
		voipRegistry.desiredPushTypes = Set([PKPushType.voIP])
	}

	public func pushRegistry(_ registry: PKPushRegistry, didUpdate credentials: PKPushCredentials, for type: PKPushType) {
		print("LOG|pushRegistry:didUpdatePushCredentials:forType:")
			if type != .voIP {
					return
			}

		guard self.deviceToken != credentials.token else { return }

		let deviceToken = credentials.token

		print("LOG|pushRegistry:attempting to register with twilio")
		if let token = self.accessToken {
				// TODO refacto, in plugin code
					TwilioVoice.register(accessToken: token, deviceToken: deviceToken) { (error) in
						if error != nil {
								print("LOG|An error occurred while registering")
								print("DEVICETOKEN")
							} else {
								print("LOG|Successfully registered for VoIP push notifications.")
							}
					}
			}
			self.deviceToken = deviceToken
	}

	public func pushRegistry(_ registry: PKPushRegistry, didInvalidatePushTokenFor type: PKPushType) {
			print("LOG|pushRegistry:didInvalidatePushTokenForType:")
			if type != .voIP {
					return
			}

			self.unregister()
	}

	func unregister() {
			guard let deviceToken = deviceToken, let token = accessToken else {
					return
			}

			self.unregisterTokens(token: token, deviceToken: deviceToken)
	}

	func unregisterTokens(token: String, deviceToken: Data) {
		// TODO refacto in another class
			TwilioVoice.unregister(accessToken: token, deviceToken: deviceToken) { (error) in
				if error != nil {
							print("LOG|An error occurred while unregistering")
					} else {
							print("LOG|Successfully unregistered from VoIP push notifications.")
					}
			}
			UserDefaults.standard.removeObject(forKey: kCachedDeviceToken)
	}

	public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType) {
			print("LOG|pushRegistry:didReceiveIncomingPushWithPayload:forType:")

			if type == PKPushType.voIP {
				TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!, delegateQueue: nil)
			}
	}

	public func pushRegistry(_ registry: PKPushRegistry, didReceiveIncomingPushWith payload: PKPushPayload, for type: PKPushType, completion: @escaping () -> Void) {
		print("LOG|pushRegistry:didReceiveIncomingPushWithPayload:forType:completion:")

			if type == PKPushType.voIP {
				TwilioVoice.handleNotification(payload.dictionaryPayload, delegate: TwilioProgrammableVoice.sharedInstance.twilioVoiceDelegate!, delegateQueue: nil)
			}

			if let version = Float(UIDevice.current.systemVersion), version < 13.0 {
					self.incomingPushCompletionCallback = completion
			} else {
					completion()
			}
	}

	func incomingPushHandled() {
			if let completion = self.incomingPushCompletionCallback {
					self.incomingPushCompletionCallback = nil
					completion()
			}
	}
}
