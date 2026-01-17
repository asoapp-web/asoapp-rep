import SwiftUI
@preconcurrency import WebKit

// MARK: - Memory Display View (WebView Screen)
struct MemoryDisplayView: View {
    @StateObject private var memoryFlowController = MemoryFlowController.shared
    
    var body: some View {
        ZStack {
            // Black background fills entire screen including Safe Area
            Color.black
                .ignoresSafeArea()
            
            // WebView with custom safe area handling
            VStack(spacing: 0) {
                MemoryWebView(
                    memoryUrl: memoryFlowController.memoryCachedEndpoint ?? "",
                    memoryOnURLUpdate: { memoryNewURL in
                        memoryFlowController.memoryUpdateURL(memoryNewURL)
                    }
                )
            }
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}

// MARK: - Memory WebView
struct MemoryWebView: UIViewRepresentable {
    let memoryUrl: String
    let memoryOnURLUpdate: (String) -> Void
    
    func makeUIView(context: Context) -> WKWebView {
        // Create configuration
        let memoryConfig = WKWebViewConfiguration()
        let memoryPreferences = WKWebpagePreferences()
        memoryPreferences.allowsContentJavaScript = true
        memoryConfig.defaultWebpagePreferences = memoryPreferences
        
        // Media playback settings
        memoryConfig.allowsInlineMediaPlayback = true
        memoryConfig.mediaTypesRequiringUserActionForPlayback = []
        memoryConfig.allowsAirPlayForMediaPlayback = true
        memoryConfig.allowsPictureInPictureMediaPlayback = true
        
        // Website data store for cookies
        memoryConfig.websiteDataStore = WKWebsiteDataStore.default()
        
        // Create WebView
        let memoryWebView = WKWebView(frame: .zero, configuration: memoryConfig)
        memoryWebView.customUserAgent = "Mozilla/5.0 (iPhone; CPU iPhone OS 18_4 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/16.0 Mobile/15E148 Safari/604.1"
        memoryWebView.scrollView.backgroundColor = .black
        memoryWebView.backgroundColor = .black
        memoryWebView.navigationDelegate = context.coordinator
        memoryWebView.uiDelegate = context.coordinator
        
        // Additional settings
        memoryWebView.allowsBackForwardNavigationGestures = true
        memoryWebView.scrollView.keyboardDismissMode = .interactive
        memoryWebView.allowsLinkPreview = false
        
        // Add pull-to-refresh
        let memoryRefreshControl = UIRefreshControl()
        memoryRefreshControl.tintColor = UIColor.white
        memoryRefreshControl.addTarget(
            context.coordinator,
            action: #selector(MemoryCoordinator.memoryHandleRefresh(_:)),
            for: .valueChanged
        )
        memoryWebView.scrollView.refreshControl = memoryRefreshControl
        memoryWebView.scrollView.bounces = true
        
        // Store reference in coordinator
        context.coordinator.memoryRefreshControl = memoryRefreshControl
        
        // Load saved cookies
        if let memoryCookieData = UserDefaults.standard.array(forKey: "memory_saved_cookies_v1") as? [Data] {
            for memoryCookieDataItem in memoryCookieData {
                if let memoryCookie = try? NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(memoryCookieDataItem) as? HTTPCookie {
                    WKWebsiteDataStore.default().httpCookieStore.setCookie(memoryCookie)
                }
            }
        }
        
        // Load URL
        if !memoryUrl.isEmpty, let memoryWebURL = URL(string: memoryUrl) {
            let memoryRequest = URLRequest(url: memoryWebURL)
            memoryWebView.load(memoryRequest)
        }
        
        return memoryWebView
    }
    
    func updateUIView(_ memoryUiView: WKWebView, context: Context) {
        // Check if URL changed and reload if needed
        if !memoryUrl.isEmpty {
            let memoryCurrentURLString = memoryUiView.url?.absoluteString ?? ""
            if memoryCurrentURLString != memoryUrl {
                print("🔄 [MemoryWebView] URL changed from '\(memoryCurrentURLString)' to '\(memoryUrl)' - reloading")
                if let memoryWebURL = URL(string: memoryUrl) {
                    let memoryRequest = URLRequest(url: memoryWebURL)
                    memoryUiView.load(memoryRequest)
                }
            }
        }
    }
    
    func makeCoordinator() -> MemoryCoordinator {
        MemoryCoordinator(self)
    }
    
    // MARK: - Coordinator
    class MemoryCoordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        let memoryParent: MemoryWebView
        private weak var memoryWebView: WKWebView?
        weak var memoryRefreshControl: UIRefreshControl?
        
        init(_ memoryParent: MemoryWebView) {
            self.memoryParent = memoryParent
            super.init()
        }
        
        @objc func memoryHandleRefresh(_ memoryRefreshControl: UIRefreshControl) {
            memoryWebView?.reload()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                memoryRefreshControl.endRefreshing()
            }
        }
        
        // MARK: - Navigation Delegate
        func webView(_ memoryWebView: WKWebView, didStartProvisionalNavigation memoryNavigation: WKNavigation!) {
            self.memoryWebView = memoryWebView
        }
        
        func webView(_ memoryWebView: WKWebView, didFinish memoryNavigation: WKNavigation!) {
            // Stop refresh control
            memoryRefreshControl?.endRefreshing()
            
            // Update URL if changed
            if let memoryCurrentURL = memoryWebView.url?.absoluteString {
                memoryParent.memoryOnURLUpdate(memoryCurrentURL)
            }
            
            // Save cookies
            WKWebsiteDataStore.default().httpCookieStore.getAllCookies { memoryCookies in
                let memoryCookieData = memoryCookies.compactMap {
                    try? NSKeyedArchiver.archivedData(withRootObject: $0, requiringSecureCoding: false)
                }
                UserDefaults.standard.set(memoryCookieData, forKey: "memory_saved_cookies_v1")
            }
        }
        
        func webView(_ memoryWebView: WKWebView, didFail memoryNavigation: WKNavigation!, withError memoryError: Error) {
            // Stop refresh control
            memoryRefreshControl?.endRefreshing()
        }
        
        func webView(_ memoryWebView: WKWebView, decidePolicyFor memoryNavigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let memoryUrl = memoryNavigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            
            let memoryScheme = memoryUrl.scheme?.lowercased() ?? ""
            
            // Handle non-web schemes (tel:, mailto:, etc.)
            if memoryScheme != "http" && memoryScheme != "https" {
                print("🔗 [MemoryWebView] Opening external URL: \(memoryUrl)")
                UIApplication.shared.open(memoryUrl)
                decisionHandler(.cancel)
                return
            }
            
            decisionHandler(.allow)
        }
        
        // MARK: - UI Delegate
        func webView(_ memoryWebView: WKWebView, createWebViewWith memoryConfiguration: WKWebViewConfiguration, for memoryNavigationAction: WKNavigationAction, windowFeatures memoryWindowFeatures: WKWindowFeatures) -> WKWebView? {
            // Handle popup windows - load in same webview
            if let memoryUrl = memoryNavigationAction.request.url {
                memoryWebView.load(URLRequest(url: memoryUrl))
            }
            return nil
        }
        
        func webView(_ memoryWebView: WKWebView, runJavaScriptAlertPanelWithMessage memoryMessage: String, initiatedByFrame memoryFrame: WKFrameInfo, completionHandler: @escaping () -> Void) {
            let memoryAlert = UIAlertController(title: nil, message: memoryMessage, preferredStyle: .alert)
            memoryAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler()
            })
            
            if let memoryWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let memoryWindow = memoryWindowScene.windows.first {
                memoryWindow.rootViewController?.present(memoryAlert, animated: true)
            }
        }
        
        func webView(_ memoryWebView: WKWebView, runJavaScriptConfirmPanelWithMessage memoryMessage: String, initiatedByFrame memoryFrame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
            let memoryAlert = UIAlertController(title: nil, message: memoryMessage, preferredStyle: .alert)
            memoryAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
                completionHandler(false)
            })
            memoryAlert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
                completionHandler(true)
            })
            
            if let memoryWindowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let memoryWindow = memoryWindowScene.windows.first {
                memoryWindow.rootViewController?.present(memoryAlert, animated: true)
            }
        }
    }
}
