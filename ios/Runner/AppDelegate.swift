import Flutter
import UIKit
import FirebaseCore
import FirebaseMessaging
import Photos
import AppTrackingTransparency

@main
@objc class AppDelegate: FlutterAppDelegate {

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // NOTE: Firebase is initialized by Flutter's firebase_core plugin via
    // Firebase.initializeApp() in main.dart. Do NOT call FirebaseApp.configure()
    // here — double initialization causes iOS crashes.

    // Register for remote notifications
    UNUserNotificationCenter.current().delegate = self
    application.registerForRemoteNotifications()

    GeneratedPluginRegistrant.register(with: self)

    // Set up MethodChannel for gallery save (mirrors Android MainActivity)
    let controller = window?.rootViewController as! FlutterViewController
    let galleryChannel = FlutterMethodChannel(
      name: "com.bardino.zodi/gallery",
      binaryMessenger: controller.binaryMessenger
    )

    galleryChannel.setMethodCallHandler { [weak self] (call, result) in
      if call.method == "saveToGallery" {
        guard let args = call.arguments as? [String: Any],
              let bytes = args["bytes"] as? FlutterStandardTypedData,
              let fileName = args["fileName"] as? String else {
          result(FlutterError(code: "INVALID_ARGS", message: "Gorsel verisi bulunamadi", details: nil))
          return
        }
        self?.saveToGallery(imageData: bytes.data, fileName: fileName, result: result)
      } else {
        result(FlutterMethodNotImplemented)
      }
    }

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  // MARK: - Gallery Save (iOS equivalent of Android MediaStore)
  private func saveToGallery(imageData: Data, fileName: String, result: @escaping FlutterResult) {
    guard let image = UIImage(data: imageData) else {
      result(FlutterError(code: "SAVE_ERROR", message: "Gorsel olusturulamadi", details: nil))
      return
    }

    PHPhotoLibrary.requestAuthorization(for: .addOnly) { status in
      guard status == .authorized || status == .limited else {
        DispatchQueue.main.async {
          result(FlutterError(code: "PERMISSION_DENIED", message: "Galeri izni reddedildi", details: nil))
        }
        return
      }

      PHPhotoLibrary.shared().performChanges({
        PHAssetChangeRequest.creationRequestForAsset(from: image)
      }) { success, error in
        DispatchQueue.main.async {
          if success {
            result(true)
          } else {
            result(FlutterError(
              code: "SAVE_ERROR",
              message: error?.localizedDescription ?? "Gorsel kaydedilemedi",
              details: nil
            ))
          }
        }
      }
    }
  }

  // MARK: - App Tracking Transparency
  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)

    // Request ATT permission after a short delay (required for AdMob)
    if #available(iOS 14, *) {
      DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
        ATTrackingManager.requestTrackingAuthorization { _ in }
      }
    }
  }

  // MARK: - Push Notification Token
  override func application(
    _ application: UIApplication,
    didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
  ) {
    Messaging.messaging().apnsToken = deviceToken
    super.application(application, didRegisterForRemoteNotificationsWithDeviceToken: deviceToken)
  }
}
