import Flutter
import UIKit

public class CacheKitPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "cache_kit", binaryMessenger: registrar.messenger())
    let instance = CacheKitPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "clear_app_data":
      result(false)
    default:
      result(FlutterMethodNotImplemented)
    }
  }
}
