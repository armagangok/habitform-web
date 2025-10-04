import Flutter
import UIKit
import WidgetKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Method channel for widget data sync
    let widgetChannel = FlutterMethodChannel(
      name: "com.appsweat.habitrise/widget",
      binaryMessenger: controller.binaryMessenger)

    widgetChannel.setMethodCallHandler({
      (call: FlutterMethodCall, result: @escaping FlutterResult) -> Void in
      switch call.method {
      case "getAppGroupContainerURL":
        self.getAppGroupContainerURL(result: result)
      case "syncHabitsToWidget":
        if let args = call.arguments as? [String: Any],
          let habitsJson = args["habits"] as? String
        {
          self.syncHabitsToWidget(habitsJson: habitsJson, result: result)
        } else {
          result(
            FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    })

    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  private func getAppGroupContainerURL(result: @escaping FlutterResult) {
    let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"

    if let containerURL = FileManager.default.containerURL(
      forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    {
      result(containerURL.path)
    } else {
      result(
        FlutterError(
          code: "CONTAINER_ERROR", message: "Failed to get app group container URL", details: nil))
    }
  }

  private func syncHabitsToWidget(habitsJson: String, result: @escaping FlutterResult) {
    let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"

    guard
      let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    else {
      result(
        FlutterError(
          code: "CONTAINER_ERROR", message: "Failed to get app group container URL", details: nil))
      return
    }

    let habitsURL = containerURL.appendingPathComponent("habits.json")

    do {
      try habitsJson.write(to: habitsURL, atomically: true, encoding: .utf8)

      // Reload widget timelines
      if #available(iOS 14.0, *) {
        WidgetCenter.shared.reloadAllTimelines()
      }

      result("Success")
    } catch {
      result(
        FlutterError(
          code: "WRITE_ERROR",
          message: "Failed to write habits data: \(error.localizedDescription)", details: nil))
    }
  }
}
