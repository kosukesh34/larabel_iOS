import SwiftUI

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("ログイン")
                .font(.largeTitle)
                .fontWeight(.bold)

            TextField("メールアドレス", text: $email)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .padding(.horizontal)

            SecureField("パスワード", text: $password)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.horizontal)

            // エラーメッセージの表示
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            Button(action: {
                login()
            }) {
                Text("ログイン")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(isLoading)
            .padding(.horizontal)

            if isLoading {
                ProgressView()
            }
        }
        .padding()
    }

    // ログイン処理
    func login() {
        isLoading = true
        errorMessage = nil

        guard let url = URL(string: "http://localhost/api/login") else {
            errorMessage = "無効なURLです"
            isLoading = false
            return
        }

        let body: [String: String] = [
            "email": email,
            "password": password
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
            errorMessage = "データのエンコードに失敗しました"
            isLoading = false
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                isLoading = false

                if let error = error {
                    errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                    return
                }

                guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
                    errorMessage = "ログインに失敗しました。ステータスコード: \((response as? HTTPURLResponse)?.statusCode ?? 0)"
                    return
                }

                guard let data = data else {
                    errorMessage = "データがありません"
                    return
                }

                // デバッグ用: レスポンスJSONをログに出力
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("レスポンスJSON: \(jsonString)")
                }

                guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    errorMessage = "JSONの解析に失敗しました"
                    return
                }

                guard let token = json["token"] as? String else {
                    errorMessage = "トークンがありません"
                    return
                }

                authToken = token
            }
        }.resume()
    }
}
