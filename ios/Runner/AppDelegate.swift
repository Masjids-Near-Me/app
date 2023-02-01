import UIKit
import Flutter

// Add this line
import WonderPush

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        if #available(iOS 10.0, *) {
            UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
        }

        GeneratedPluginRegistrant.register(with: self)

        // Add the following 5 lines
        WonderPush.setClientId("b6eb4d13afecea1e6a5bded8d68c423350c2047e", secret: "0e0aa8e576a75d2fc5ceccc8de2a11a5f3fb02d4093575e65282e5dcc745e440")
        WonderPush.setupDelegate(for: application)
        if #available(iOS 10.0, *) {
            WonderPush.setupDelegateForUserNotificationCenter()
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}