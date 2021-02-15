import UIKit
import Flutter
import Firebase
import TwilioVoice
import workmanager
import PushKit


@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    FirebaseApp.configure()

		
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
		
    GeneratedPluginRegistrant.register(with: self)
    WorkmanagerPlugin.setPluginRegistrantCallback { registry in
        // registry in this case is the FlutterEngine that is created in Workmanager's performFetchWithCompletionHandler
        // This will make other plugins available during a background fetch
        GeneratedPluginRegistrant.register(with: registry)
    }
    // this start a background job on the iOS system then it trigger the dart callBackDispatcher
		UIApplication.shared.setMinimumBackgroundFetchInterval(TimeInterval(60*15))
		
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  override func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
      completionHandler(.alert) // shows banner even if app is in foreground
  }
}
