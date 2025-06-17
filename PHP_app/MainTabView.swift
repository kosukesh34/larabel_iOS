//
//  MainTabView.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/17/25.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("ホーム", systemImage: "house")
                }

            ContentView()
                .tabItem {
                    Label("バーコード", systemImage: "qrcode.viewfinder")
                }

            NotificationView()
                .tabItem {
                    Label("お知らせ", systemImage: "bell")
                }

            SettingsView()
                .tabItem {
                    Label("設定", systemImage: "gearshape")
                }
        }
    }
}
