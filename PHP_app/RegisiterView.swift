import SwiftUI
import Alamofire

@available(iOS 16.0, *)
struct RegisterView: View {
    @State private var name: String = ""
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var showPassword: Bool = false
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        NavigationStack {
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

                ZStack(alignment: .trailing) {
                    if showPassword {
                        TextField("パスワード", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    } else {
                        SecureField("パスワード", text: $password)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    Button(action: { showPassword.toggle() }) {
                        Image(systemName: showPassword ? "eye.slash" : "eye")
                            .foregroundColor(.gray)
                            .padding(.trailing, 10)
                    }
                }
                .padding(.horizontal)

                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: { register() }) {
                    Text("登録")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .disabled(isLoading || name.isEmpty || email.isEmpty || password.isEmpty)
                .padding(.horizontal)

                if isLoading {
                    ProgressView()
                }
            }
            .padding()
            .navigationTitle("新規登録")
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    func register() {
        isLoading = true
        errorMessage = nil
        print("登録処理開始: name=\(name), email=\(email)")

        let parameters: [String: String] = [
            "name": name,
            "email": email,
            "password": password
        ]

        AF.request("http://192.168.0.155/api/register",
                   method: .post,
                   parameters: parameters,
                   encoder: JSONParameterEncoder.default)
            .validate(statusCode: 200..<300)
            .responseDecodable(of: RegisterResponse.self) { response in
                // デバッグ用ログ
                if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                    print("サーバーからのレスポンス: \(jsonString)")
                }

                DispatchQueue.main.async {
                    isLoading = false
                    switch response.result {
                    case .success(let registerResponse):
                        print("レスポンス解析: message=\(registerResponse.message ?? "なし"), token=\(registerResponse.token ?? "なし")")
                        if let token = registerResponse.token {
                            print("登録成功: トークン=\(token)")
                            authToken = token // トークンを保存
                        } else {
                            errorMessage = "トークンが取得できませんでした"
                            print("エラー: トークンがレスポンスに含まれていません")
                        }
                    case .failure(let error):
                        errorMessage = "登録に失敗しました: \(error.localizedDescription)"
                        print("登録失敗: \(error)")
                    }
                }
            }
    }
}

struct RegisterResponse: Codable {
    let message: String?
    let user: User?
    let token: String?
}
