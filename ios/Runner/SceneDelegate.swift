import Flutter
import UIKit
import WidgetKit

class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let windowScene = scene as? UIWindowScene,
          let controller = windowScene.windows.first?.rootViewController as? FlutterViewController else {
      return
    }

    let channel = FlutterMethodChannel(name: "efu.me.timetable/widget", binaryMessenger: controller.binaryMessenger)

    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "getAppGroupPath":
        guard let groupId = call.arguments as? String else {
          result(nil)
          return
        }
        let url = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: groupId)
        result(url?.path)
      case "reloadWidget":
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
        }
        result(nil)
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
