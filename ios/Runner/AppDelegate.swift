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

    // Widget communication is handled via shared files

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
      case "completeHabit":
        if let args = call.arguments as? [String: Any],
          let habitId = args["habitId"] as? String,
          let dateString = args["date"] as? String
        {
          self.completeHabitFromWidget(habitId: habitId, dateString: dateString, result: result)
        } else {
          result(
            FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "updateHabitCompletion":
        if let args = call.arguments as? [String: Any],
          let habitId = args["habitId"] as? String,
          let dateString = args["date"] as? String,
          let isCompleted = args["isCompleted"] as? Bool,
          let count = args["count"] as? Int
        {
          self.updateHabitCompletionFromWidget(
            habitId: habitId, dateString: dateString, isCompleted: isCompleted, count: count,
            result: result)
        } else {
          result(
            FlutterError(code: "INVALID_ARGUMENTS", message: "Invalid arguments", details: nil))
        }
      case "getHabits":
        self.getHabitsFromWidget(result: result)
      case "getAppGroupContainerPath":
        self.getAppGroupContainerPath(result: result)
      case "forceReloadWidgetTimelines":
        self.forceReloadWidgetTimelines(result: result)
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
      // Write to temporary file first for atomic operation
      let tempURL = containerURL.appendingPathComponent("habits.json.tmp")
      try habitsJson.write(to: tempURL, atomically: true, encoding: .utf8)

      // Atomically move to final location
      if FileManager.default.fileExists(atPath: habitsURL.path) {
        try FileManager.default.removeItem(at: habitsURL)
      }
      try FileManager.default.moveItem(at: tempURL, to: habitsURL)

      print("✅ AppDelegate: Successfully wrote habits data to \(habitsURL.path)")

      // Verify the file was written correctly
      if let data = try? Data(contentsOf: habitsURL),
        let jsonObject = try? JSONSerialization.jsonObject(with: data) as? [Any]
      {
        print("✅ AppDelegate: Verified habits.json contains \(jsonObject.count) habits")
      } else {
        print("❌ AppDelegate: Failed to verify habits.json content")
      }

      // Add a small delay to ensure file is written before reloading widgets
      DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
        // Reload widget timelines
        if #available(iOS 14.0, *) {
          WidgetCenter.shared.reloadAllTimelines()
          print("🔄 AppDelegate: Reloaded all widget timelines")
        }
      }

      result("Success")
    } catch {
      result(
        FlutterError(
          code: "WRITE_ERROR",
          message: "Failed to write habits data: \(error.localizedDescription)", details: nil))
    }
  }

  private func completeHabitFromWidget(
    habitId: String, dateString: String, result: @escaping FlutterResult
  ) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else {
      result(FlutterError(code: "INVALID_DATE", message: "Invalid date format", details: nil))
      return
    }

    // Write completion update to shared file for Flutter to pick up
    writeCompletionUpdate(habitId: habitId, date: date, isCompleted: true, count: 1)

    // Reload widget timelines
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }

    result(["success": true])
  }

  private func updateHabitCompletionFromWidget(
    habitId: String, dateString: String, isCompleted: Bool, count: Int,
    result: @escaping FlutterResult
  ) {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    guard let date = formatter.date(from: dateString) else {
      result(FlutterError(code: "INVALID_DATE", message: "Invalid date format", details: nil))
      return
    }

    // Write completion update to shared file for Flutter to pick up
    writeCompletionUpdate(habitId: habitId, date: date, isCompleted: isCompleted, count: count)

    // Reload widget timelines
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
    }

    result(["success": true])
  }

  private func getHabitsFromWidget(result: @escaping FlutterResult) {
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
      if FileManager.default.fileExists(atPath: habitsURL.path) {
        let data = try Data(contentsOf: habitsURL)
        let habits = try JSONSerialization.jsonObject(with: data)
        result(["habits": habits])
      } else {
        result(["habits": []])
      }
    } catch {
      result(
        FlutterError(
          code: "READ_ERROR", message: "Failed to read habits data: \(error.localizedDescription)",
          details: nil))
    }
  }

  private func writeCompletionUpdate(habitId: String, date: Date, isCompleted: Bool, count: Int) {
    let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"

    guard
      let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier)
    else {
      print("Failed to get app group container URL")
      return
    }

    let updatesURL = containerURL.appendingPathComponent("completion_updates.json")

    do {
      // Read existing updates
      var updates: [[String: Any]] = []
      if FileManager.default.fileExists(atPath: updatesURL.path) {
        let data = try Data(contentsOf: updatesURL)
        updates = try JSONSerialization.jsonObject(with: data) as? [[String: Any]] ?? []
      }

      // Add new update
      let formatter = DateFormatter()
      formatter.dateFormat = "yyyy-MM-dd"
      let update: [String: Any] = [
        "habitId": habitId,
        "completion": [
          "id": "\(habitId)_\(formatter.string(from: date))",
          "date": formatter.string(from: date),
          "isCompleted": isCompleted,
          "count": count,
        ],
        "timestamp": ISO8601DateFormatter().string(from: Date()),
      ]

      updates.append(update)

      // Keep only last 100 updates
      if updates.count > 100 {
        updates = Array(updates.suffix(100))
      }

      // Write back to file
      let data = try JSONSerialization.data(withJSONObject: updates)
      try data.write(to: updatesURL)

    } catch {
      print("Error writing completion update: \(error)")
    }
  }

  private func getAppGroupContainerPath(result: @escaping FlutterResult) {
    let appGroupIdentifier = "group.com.AppSweat.HabitFormWidget"

    guard
      let containerURL = FileManager.default.containerURL(
        forSecurityApplicationGroupIdentifier: appGroupIdentifier
      )
    else {
      result(
        FlutterError(
          code: "CONTAINER_ERROR",
          message: "Failed to get app group container URL",
          details: nil
        ))
      return
    }

    print("📁 AppDelegate: App Group container path: \(containerURL.path)")
    result(containerURL.path)
  }

  private func forceReloadWidgetTimelines(result: @escaping FlutterResult) {
    if #available(iOS 14.0, *) {
      WidgetCenter.shared.reloadAllTimelines()
      print("🔄 AppDelegate: Force reloaded all widget timelines")
      result("Success")
    } else {
      result(
        FlutterError(
          code: "UNSUPPORTED_VERSION",
          message: "WidgetKit requires iOS 14.0 or later",
          details: nil
        ))
    }
  }
}
