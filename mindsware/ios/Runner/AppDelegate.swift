import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
    
    // Ekran süresi verisini alacak method kanalı
    private let screenTimeChannel = "com.example.usage_stats"

    override func application(
      _ application: UIApplication,
      didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        // Flutter'ın plugin'lerini kaydediyoruz
        GeneratedPluginRegistrant.register(with: self)

        // MethodChannel kurulumunu yapıyoruz
        let controller = window?.rootViewController as! FlutterViewController
        let screenTimeChannel = FlutterMethodChannel(name: screenTimeChannel,
                                                     binaryMessenger: controller.binaryMessenger)

        // MethodChannel ile ekran süresi verilerini almak için listener ekliyoruz
        screenTimeChannel.setMethodCallHandler { (call, result) in
            if call.method == "getUsageStats" {
                // Şimdilik boş bırakılıyor, çünkü iOS bu verileri doğrudan veremez
                result(FlutterError(code: "UNAVAILABLE", message: "iOS does not support usage stats", details: nil))
            } else {
                result(FlutterMethodNotImplemented)
            }
        }

        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}

