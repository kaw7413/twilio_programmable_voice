//import UIKit
//import Flutter
//import Firebase
//
//@UIApplicationMain
//@objc class AppDelegate: FlutterAppDelegate, MessagingDelegate {
//  override func application(
//    _ application: UIApplication,
//    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
//  ) -> Bool {
//    FirebaseApp.configure()
//
//
//    // MethodChannel related
//    let controller : FlutterViewController = window?.rootViewController as! FlutterViewController
//    let methodChannel = FlutterMethodChannel(name: "twilio_programmable_voice",
//                                              binaryMessenger: controller.binaryMessenger)
//
//    methodChannel.setMethodCallHandler({
//      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
//      // Note: this method is invoked on the UI thread.
//      // Handle battery messages.
//        // Note: this method is invoked on the UI thread.
//        guard call.method == "getBatteryLevel" else {
//          result(FlutterMethodNotImplemented)
//          return
//        }
//        self.receiveBatteryLevel(result: result)
//    })
//
//    if #available(iOS 10.0, *) {
//      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
//    }
//
//    Messaging.messaging().delegate = self
//
//    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
//  }
//
//    private func receiveBatteryLevel(result: FlutterResult) {
//      let device = UIDevice.current
//      device.isBatteryMonitoringEnabled = true
//      if device.batteryState == UIDevice.BatteryState.unknown {
//        result(FlutterError(code: "UNAVAILABLE",
//                            message: "Battery info unavailable",
//                            details: nil))
//      } else {
//        result(Int(device.batteryLevel * 100))
//      }
//    }
//
//
////  override init() {
////    // don't use this in the application method
////    FirebaseApp.configure()
////  }
//}


import UIKit
import Flutter

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self
    }
    
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
