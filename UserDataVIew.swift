//
//  UserDataVIew.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/15/25.
//
import SwiftUI

struct UserDataView: View {
    let userData: [String: Any]

    var body: some View {
        VStack {
            Text("ユーザーデータ")
                .font(.headline)
            ForEach(userData.keys.sorted(), id: \.self) { key in
                if let value = userData[key] {
                    Text("\(key): \(String(describing: value))")
                }
            }
        }
        .padding()
    }
}
