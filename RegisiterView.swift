//
//  RegisiterView.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/15/25.
//

import SwiftUI
import Alamofire

struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 20) {
            Text("新規登録")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("名前", text: $name)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                register()
            }) {
                Text("登録")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            .padding(.horizontal)

            Button(action: {
                dismiss()
            }) {
                Text("キャンセル")
                    .foregroundColor(.red)
            }
            .padding(.top)

            if isLoading {
                ProgressView()
            }
        }
        .padding()
        .navigationTitle("新規登録")
    }

    func register() {
        isLoading = true
        errorMessage = nil

        let parameters: [String: String] = [
            "name": name,
            "email": email,
            "password": password
        ]

        AF.request("http://localhost/api/users", method: .post, parameters: parameters, encoding: JSONEncoding.default)
            .responseDecodable(of: RegisterResponse.self) { response in
                isLoading = false

                switch response.result {
                case .success(let registerResponse):
                    if let message = registerResponse.message, message.contains("成功") {
                        dismiss() // 登録成功後、ログインビューに戻る
                    } else {
                        errorMessage = registerResponse.message ?? "登録に失敗しました"
                    }
                case .failure(let error):
                    errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                }
            }
    }
}

struct RegisterResponse: Codable {
    let message: String?
    let user: User?
}
