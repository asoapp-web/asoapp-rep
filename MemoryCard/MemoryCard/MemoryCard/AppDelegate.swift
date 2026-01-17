import UIKit
import AppsFlyerLib
import AppTrackingTransparency

// MARK: - App Delegate
class AppDelegate: NSObject, UIApplicationDelegate {
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure AppsFlyer
        memoryConfigureAppsFlyer()
        
        // Start AppsFlyer when app becomes active
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(memoryStartAppsFlyer),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        
        return true
    }
    
    private func memoryConfigureAppsFlyer() {
        // Set AppsFlyer Dev Key
        AppsFlyerLib.shared().appsFlyerDevKey = "GMbycebmqbk7tjeRmygSpU"
        
        // Set Apple App ID
        AppsFlyerLib.shared().appleAppID = "6757203309"
        
        // Set delegate
        AppsFlyerLib.shared().delegate = self
        
        // ВАЖНО: Ждём ATT перед стартом для получения полного AppsFlyer ID
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: 60)
        
        print("📱 [AppDelegate] AppsFlyer configured")
    }
    
    private static var memoryWasStarted = false
    
    @objc private func memoryStartAppsFlyer() {
        // Запрашиваем ATT ПЕРЕД стартом AppsFlyer
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] memoryStatus in
                print("📱 [AppDelegate] Tracking authorization: \(memoryStatus.rawValue)")
                self?.memoryLaunchAppsFlyer()
            }
        } else {
            memoryLaunchAppsFlyer()
        }
    }
    
    private func memoryLaunchAppsFlyer() {
        guard !Self.memoryWasStarted else { return }
        Self.memoryWasStarted = true
        
        AppsFlyerLib.shared().start()
        
        let memoryUid = AppsFlyerLib.shared().getAppsFlyerUID()
        print("📱 [AppDelegate] AppsFlyer started, UID: \(memoryUid)")
    }
}

// MARK: - AppsFlyer Delegate
extension AppDelegate: AppsFlyerLibDelegate {
    
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable: Any]) {
        print("✅ [AppDelegate] AppsFlyer conversion data received")
        
        // Get AppsFlyer UID
        let memoryAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID: \(memoryAppsFlyerUID), length: \(memoryAppsFlyerUID.count)")
        
        // Update MemoryFlowController with AppsFlyer data
        MemoryFlowController.shared.memoryUpdateAppsFlyerData(
            memoryUid: memoryAppsFlyerUID,
            memoryConversionData: conversionInfo
        )
    }
    
    func onConversionDataFail(_ error: Error) {
        print("❌ [AppDelegate] AppsFlyer conversion data failed: \(error.localizedDescription)")
        
        // Use default UID if available
        let memoryAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
        print("🔑 [AppDelegate] AppsFlyer UID (fallback): \(memoryAppsFlyerUID), length: \(memoryAppsFlyerUID.count)")
        
        if !memoryAppsFlyerUID.isEmpty {
            MemoryFlowController.shared.memoryUpdateAppsFlyerData(memoryUid: memoryAppsFlyerUID, memoryConversionData: [:])
        }
    }
}
