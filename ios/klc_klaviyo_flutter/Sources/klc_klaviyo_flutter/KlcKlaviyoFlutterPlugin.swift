import Flutter
import UIKit
import KlaviyoSwift
import KlaviyoForms
import UserNotifications

public class KlcKlaviyoFlutterPlugin: NSObject, FlutterPlugin, UNUserNotificationCenterDelegate {

    private var channel: FlutterMethodChannel?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "com.klaviyo.flutter/klaviyo_sdk",
            binaryMessenger: registrar.messenger()
        )
        let instance = KlcKlaviyoFlutterPlugin()
        instance.channel = channel
        registrar.addMethodCallDelegate(instance, channel: channel)
        registrar.addApplicationDelegate(instance)

        // Set as notification delegate to handle foreground notifications and taps
        UNUserNotificationCenter.current().delegate = instance
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handle: Method called - \(call.method)")
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "setEmail":
            handleSetEmail(call, result: result)
        case "setPhoneNumber":
            handleSetPhoneNumber(call, result: result)
        case "setExternalId":
            handleSetExternalId(call, result: result)
        case "setProfile":
            handleSetProfile(call, result: result)
        case "resetProfile":
            handleResetProfile(result: result)
        case "createEvent":
            handleCreateEvent(call, result: result)
        case "setPushToken":
            handleSetPushToken(call, result: result)
        case "getPushToken":
            handleGetPushToken(result: result)
        case "requestPushPermission":
            handleRequestPushPermission(result: result)
        case "getPushPermissionStatus":
            handleGetPushPermissionStatus(result: result)
        case "getEmail":
            result(KlaviyoSDK().email)
        case "getPhoneNumber":
            result(KlaviyoSDK().phoneNumber)
        case "getExternalId":
            result(KlaviyoSDK().externalId)
        case "registerForInAppForms":
            handleRegisterForInAppForms(result: result)
        case "unregisterFromInAppForms":
            handleUnregisterFromInAppForms(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    // MARK: - Initialize
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleInitialize: Starting initialization")
        guard let args = call.arguments as? [String: Any],
              let apiKey = args["apiKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "API key is required", details: nil))
            return
        }
        KlaviyoSDK().initialize(with: apiKey)
        print("[KlcKlaviyoFlutterPlugin] handleInitialize: SDK initialized successfully")
        result(nil)
    }
    
    // MARK: - Profile Management
    
    private func handleSetEmail(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleSetEmail: Setting email")
        guard let args = call.arguments as? [String: Any],
              let email = args["email"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Email is required", details: nil))
            return
        }
        KlaviyoSDK().set(email: email)
        reRegisterStoredPushTokenIfAvailable()
        print("[KlcKlaviyoFlutterPlugin] handleSetEmail: Email set successfully")
        result(nil)
    }
    
    private func handleSetPhoneNumber(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleSetPhoneNumber: Setting phone number")
        guard let args = call.arguments as? [String: Any],
              let phoneNumber = args["phoneNumber"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Phone number is required", details: nil))
            return
        }
        KlaviyoSDK().set(phoneNumber: phoneNumber)
        reRegisterStoredPushTokenIfAvailable()
        print("[KlcKlaviyoFlutterPlugin] handleSetPhoneNumber: Phone number set successfully")
        result(nil)
    }
    
    private func handleSetExternalId(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleSetExternalId: Setting external ID")
        guard let args = call.arguments as? [String: Any],
              let externalId = args["externalId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "External ID is required", details: nil))
            return
        }
        KlaviyoSDK().set(externalId: externalId)
        reRegisterStoredPushTokenIfAvailable()
        print("[KlcKlaviyoFlutterPlugin] handleSetExternalId: External ID set successfully")
        result(nil)
    }
    
    private func handleSetProfile(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleSetProfile: Setting profile")
        guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Profile data is required", details: nil))
            return
        }

        var location: Profile.Location?
        if let locationData = args["location"] as? [String: Any] {
            location = Profile.Location(
                address1: locationData["address1"] as? String,
                address2: locationData["address2"] as? String,
                city: locationData["city"] as? String,
                country: locationData["country"] as? String,
                latitude: locationData["latitude"] as? Double,
                longitude: locationData["longitude"] as? Double,
                region: locationData["region"] as? String,
                zip: locationData["zip"] as? String,
                timezone: locationData["timezone"] as? String
            )
        }
        
        let profile = Profile(
            email: args["email"] as? String,
            phoneNumber: args["phoneNumber"] as? String,
            externalId: args["externalId"] as? String,
            firstName: args["firstName"] as? String,
            lastName: args["lastName"] as? String,
            organization: args["organization"] as? String,
            title: args["title"] as? String,
            image: args["image"] as? String,
            location: location,
            properties: args["properties"] as? [String: Any]
        )
        
        KlaviyoSDK().set(profile: profile)
        reRegisterStoredPushTokenIfAvailable()
        print("[KlcKlaviyoFlutterPlugin] handleSetProfile: Profile set successfully")
        result(nil)
    }
    
    private func handleResetProfile(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleResetProfile: Resetting profile")
        KlaviyoSDK().resetProfile()
        print("[KlcKlaviyoFlutterPlugin] handleResetProfile: Profile reset successfully")
        result(nil)
    }
    
    // MARK: - Event Tracking
    
    private func handleCreateEvent(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleCreateEvent: Creating event")
        guard let args = call.arguments as? [String: Any],
              let eventName = args["name"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Event name is required", details: nil))
            return
        }

        let event = Event(
            name: .customEvent(eventName),
            properties: args["properties"] as? [String: Any],
            value: args["value"] as? Double,
            uniqueId: args["uniqueId"] as? String
        )

        KlaviyoSDK().create(event: event)
        print("[KlcKlaviyoFlutterPlugin] handleCreateEvent: Event created successfully")
        result(nil)
    }
    
    // MARK: - Push Notifications
    
    private func handleRequestPushPermission(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleRequestPushPermission: Requesting push permission")
        #if targetEnvironment(simulator)
        result(FlutterError(code: "SIMULATOR", message: "Push unavailable on Simulator", details: nil))
        return
        #else
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                result(FlutterError(code: "PERMISSION_ERROR", message: error.localizedDescription, details: nil))
                return
            }
            guard granted else {
                result(FlutterError(code: "PERMISSION_DENIED", message: "User denied permission", details: nil))
                return
            }
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                result(nil)
            }
        }
        #endif
    }
    
    private func handleGetPushPermissionStatus(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleGetPushPermissionStatus: Getting push permission status")
        #if targetEnvironment(simulator)
        result("unavailable_simulator")
        #else
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            let status: String
            switch settings.authorizationStatus {
            case .notDetermined: status = "not_determined"
            case .denied: status = "denied"
            case .authorized: status = "authorized"
            case .provisional: status = "provisional"
            case .ephemeral: status = "ephemeral"
            @unknown default: status = "unknown"
            }
            result(status)
        }
        #endif
    }
    
    private func handleSetPushToken(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleSetPushToken: Setting push token")
        guard let args = call.arguments as? [String: Any],
              let tokenString = args["token"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Push token is required", details: nil))
            return
        }
        let trimmed = tokenString.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            result(FlutterError(code: "INVALID_TOKEN", message: "Invalid push token", details: nil))
            return
        }
        KlaviyoSDK().set(pushToken: trimmed)
        UserDefaults.standard.set(trimmed, forKey: "klaviyo_push_token")
        print("[KlcKlaviyoFlutterPlugin] handleSetPushToken: Push token set successfully")
        result(nil)
    }
    
    private func reRegisterStoredPushTokenIfAvailable() {
        guard let token = UserDefaults.standard.string(forKey: "klaviyo_push_token"),
              !token.isEmpty else {
            return
        }
        KlaviyoSDK().set(pushToken: token)
        print("[KlcKlaviyoFlutterPlugin] reRegisterStoredPushTokenIfAvailable: Token re-registered successfully")
    }
    
    private func handleGetPushToken(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleGetPushToken: Getting stored push token")
        let token = UserDefaults.standard.string(forKey: "klaviyo_push_token")
        result(token)
    }
    
    // MARK: - In-App Forms
    
    private func handleRegisterForInAppForms(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleRegisterForInAppForms: Registering for in-app forms")
        Task { @MainActor in
            KlaviyoSDK().registerForInAppForms()
            result(nil)
        }
    }
    
    private func handleUnregisterFromInAppForms(result: @escaping FlutterResult) {
        print("[KlcKlaviyoFlutterPlugin] handleUnregisterFromInAppForms: Unregistering from in-app forms")
        Task { @MainActor in
            KlaviyoSDK().unregisterFromInAppForms()
            result(nil)
        }
    }
    
    // MARK: - Application Delegate (for push token)
    
    public func application(_ application: UIApplication,
                           didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        print("[KlcKlaviyoFlutterPlugin] didRegisterForRemoteNotificationsWithDeviceToken: Received device token")
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        KlaviyoSDK().set(pushToken: deviceToken)
        UserDefaults.standard.set(tokenString, forKey: "klaviyo_push_token")
        channel?.invokeMethod("onPushTokenReceived", arguments: ["token": tokenString])
        print("[KlcKlaviyoFlutterPlugin] didRegisterForRemoteNotificationsWithDeviceToken: Token registered and sent to Flutter")
    }
    
    public func application(_ application: UIApplication,
                           didFailToRegisterForRemoteNotificationsWithError error: Error) {
        channel?.invokeMethod("onPushTokenRegistrationFailed", arguments: ["error": error.localizedDescription])
        print("[KlcKlaviyoFlutterPlugin] didFailToRegisterForRemoteNotificationsWithError: Error sent to Flutter")
    }

    // MARK: - UNUserNotificationCenterDelegate

    /// Handle notification when app is in FOREGROUND
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo
        print("[KlcKlaviyoFlutterPlugin] userNotificationCenter:willPresent: Notification received (foreground): \(userInfo)")

        // Show notification banner even when app is in foreground
        if #available(iOS 14.0, *) {
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.alert, .sound, .badge])
        }
    }

    /// Handle notification when user TAPS on it
    public func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Handle Klaviyo push opened event
        KlaviyoSDK().handle(notificationResponse: response, withCompletionHandler: completionHandler)

        // Notify Flutter about the tap
        channel?.invokeMethod("onNotificationTapped", arguments: userInfo)
        print("[KlcKlaviyoFlutterPlugin] userNotificationCenter:didReceive: Notification tap sent to Flutter")
    }
}
