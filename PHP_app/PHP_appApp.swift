//
//  PHP_appApp.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//

import SwiftUI

@main
struct PHP_appApp: App {
    @AppStorage("authToken") private var authToken: String?

    var body: some Scene {
        WindowGroup {
            if authToken != nil {
                MainTabView()
            } else {
                LoginView()
            }
        }
    }
}
