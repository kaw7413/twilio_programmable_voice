import UIKit
import Flutter
import Firebase

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      // For iOS 10 display notification (sent via APNS)
      UNUserNotificationCenter.current().delegate = self
// TODO remove comment if the app start without it
//      let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
//      UNUserNotificationCenter.current().requestAuthorization(
//        options: authOptions,
//        completionHandler: {_, _ in })
    }
    
//    GeneratedPluginRegistrant.register(with: self)
    
//    firebase_messaging set up

//    else {
//      let settings: UIUserNotificationSettings =
//      UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
//      application.registerUserNotificationSettings(settings)
//    }
//
//    application.registerForRemoteNotifications()
    
//    Messaging.messaging().delegate = self
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
    
  override init() {
    FirebaseApp.configure()
  }
}
