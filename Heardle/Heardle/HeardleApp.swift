//
//  HeardleApp.swift
//  Heardle
//
//  Created by Jed Patterson on 17/07/2025.
//

import SwiftUI
import PostHog

@main
struct HeardleApp: App {
    
    init() {
        #if !DEBUG
        let POSTHOG_API_KEY = "phc_vwqGy6ffsPbvBWsLeJ1MMca5pLREZEjWYCSD4t0hXdl"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        let configuration = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        configuration.sessionReplay = true
        configuration.sessionReplayConfig.maskAllTextInputs = false
        configuration.sessionReplayConfig.screenshotMode = true
        configuration.captureScreenViews = true
        configuration.captureApplicationLifecycleEvents = true

        PostHogSDK.shared.setup(configuration)
        
        let userDefaults = UserDefaults.standard
        let userIDKey = "HeardleUserID"
        
        var userID: String
        if let existingUserID = userDefaults.string(forKey: userIDKey) {
            userID = existingUserID
        } else {
            userID = UUID().uuidString
            userDefaults.set(userID, forKey: userIDKey)
        }
        
        PostHogSDK.shared.identify(userID)
        #endif
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
