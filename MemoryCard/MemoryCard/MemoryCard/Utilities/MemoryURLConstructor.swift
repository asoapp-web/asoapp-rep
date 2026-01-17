import Foundation

// MARK: - Memory URL Constructor
// Формирование URL с параметрами AppFlyer для Keitaro (БЕЗ geo и device)
struct MemoryURLConstructor {
    
    private static let memoryBaseURL = "https://newteam-online.com/Ff9KKwHQ"
    
    /// Формирует финальный URL с параметрами для Keitaro
    static func memoryBuildURL(
        memoryAppsFlyerUID: String,
        memoryConversionData: [AnyHashable: Any] = [:]
    ) -> String {
        guard var memoryComponents = URLComponents(string: memoryBaseURL) else {
            return memoryBaseURL
        }
        
        var memoryQueryItems: [URLQueryItem] = []
        
        // === Параметры по шаблону Keitaro ===
        
        // Google Ads параметры
        let memoryGadid = memoryExtractValue(from: memoryConversionData, memoryKeys: ["gadid", "af_gadid", "adgroup_id"])
        
        memoryQueryItems.append(URLQueryItem(name: "gadid", value: memoryGadid))
        
        // AppsFlyer ID
        memoryQueryItems.append(URLQueryItem(name: "appsflyerId", value: memoryAppsFlyerUID))
        
        // Campaign параметры
        let memoryAfAdId = memoryExtractValue(from: memoryConversionData, memoryKeys: ["af_ad_id", "ad_id", "af_ad"])
        let memoryCampaignId = memoryExtractValue(from: memoryConversionData, memoryKeys: ["campaign_id", "af_campaign_id"])
        let memorySourceAppId = memoryExtractValue(from: memoryConversionData, memoryKeys: ["source_app_id", "af_source_app_id"])
        let memoryCampaign = memoryExtractValue(from: memoryConversionData, memoryKeys: ["campaign", "c", "af_c"])
        let memoryAfAd = memoryExtractValue(from: memoryConversionData, memoryKeys: ["af_ad", "ad"])
        let memoryAfAdset = memoryExtractValue(from: memoryConversionData, memoryKeys: ["af_adset", "adset"])
        let memoryAfAdsetId = memoryExtractValue(from: memoryConversionData, memoryKeys: ["af_adset_id", "adset_id"])
        let memoryNetwork = memoryExtractValue(from: memoryConversionData, memoryKeys: ["network", "af_network", "media_source", "pid"])
        
        memoryQueryItems.append(URLQueryItem(name: "af_ad_id", value: memoryAfAdId))
        memoryQueryItems.append(URLQueryItem(name: "campaign_id", value: memoryCampaignId))
        memoryQueryItems.append(URLQueryItem(name: "source_app_id", value: memorySourceAppId))
        memoryQueryItems.append(URLQueryItem(name: "campaign", value: memoryCampaign))
        memoryQueryItems.append(URLQueryItem(name: "af_ad", value: memoryAfAd))
        memoryQueryItems.append(URLQueryItem(name: "af_adset", value: memoryAfAdset))
        memoryQueryItems.append(URLQueryItem(name: "af_adset_id", value: memoryAfAdsetId))
        memoryQueryItems.append(URLQueryItem(name: "network", value: memoryNetwork))
        
        memoryComponents.queryItems = memoryQueryItems
        
        guard let memoryFinalURL = memoryComponents.url?.absoluteString else {
            return memoryBaseURL
        }
        
        print("🔗 [MemoryURLConstructor] Built URL with \(memoryQueryItems.count) parameters")
        return memoryFinalURL
    }
    
    // MARK: - Private Helpers
    
    /// Извлекает значение из conversion data по списку возможных ключей
    private static func memoryExtractValue(from memoryData: [AnyHashable: Any], memoryKeys: [String]) -> String {
        for memoryKey in memoryKeys {
            if let memoryValue = memoryData[memoryKey] {
                let memoryStringValue = String(describing: memoryValue)
                if !memoryStringValue.isEmpty && memoryStringValue != "null" && memoryStringValue != "<null>" {
                    return memoryStringValue
                }
            }
        }
        return ""
    }
}
