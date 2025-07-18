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
        let POSTHOG_API_KEY = "phc_vwqGy6ffsPbvBWsLeJ1MMca5pLREZEjWYCSD4t0hXdl"
        let POSTHOG_HOST = "https://us.i.posthog.com"
        let configuration = PostHogConfig(apiKey: POSTHOG_API_KEY, host: POSTHOG_HOST)
        PostHogSDK.shared.setup(configuration)
    }
    
    var body: some Scene {
        WindowGroup {
            HomeView()
        }
    }
}
