import Flutter
import UIKit

public class SwiftTwilioProgrammableVoicePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "twilio_programmable_voice", binaryMessenger: registrar.messenger())
    let instance = SwiftTwilioProgrammableVoicePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    
    if (call.method == "getBatteryLevel") {
        self.receiveBatteryLevel(result: result);
        return;
    }

    result("iOS " + UIDevice.current.systemVersion)
  }
    
  private func receiveBatteryLevel(result: FlutterResult) {
    let device = UIDevice.current
    device.isBatteryMonitoringEnabled = true
      if device.batteryState == UIDevice.BatteryState.unknown {
        result(FlutterError(code: "UNAVAILABLE",
                            message: "Battery info unavailable",
                            details: nil))
      } else {
      result(Int(device.batteryLevel * 100))
    }
  }
}
