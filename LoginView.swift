import SwiftUI
import Alamofire

struct LoginView: View {
    @State private var email: String = ""
    @State private var password: String = ""
    @State private var errorMessage: String?
    @State private var isLoading: Bool = false
    @State private var isShowingRegister: Bool = false
    @State private var showPassword: Bool = false
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("ログイン")
                    .font(.largeTitle)
                    .fontWeight(.bold)

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

                    // 表示/非表示トグルボタン
                    Button(action: {
                        showPassword.toggle()
                    }) {
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

                Button(action: {
                    isShowingRegister = true
                }) {
                    Text("会員登録はこちら")
                        .foregroundColor(.blue)
                        .font(.caption)
                }

                if isLoading {
                    ProgressView()
                }
            }
            .padding()
            .navigationTitle("")
            .navigationBarHidden(true)
            .sheet(isPresented: $isShowingRegister) {
                RegisterView()
            }
        }
    }

    func login() {
        isLoading = true
        errorMessage = nil

        let url = "http://localhost/api/login"
        let parameters: [String: String] = [
            "email": email,
            "password": password
        ]

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: ["Content-Type": "application/json"])
            .validate(statusCode: 200..<300)
            .responseDecodable(of: LoginResponse.self) { response in
                print("リクエスト: \(response.request?.debugDescription ?? "不明")")
                if let data = response.data, let jsonString = String(data: data, encoding: .utf8) {
                    print("レスポンスJSON: \(jsonString)")
                }

                DispatchQueue.main.async {
                    isLoading = false

                    switch response.result {
                    case .success(let value):
                        authToken = value.token
                        print("ログイン成功: トークン = \(value.token ?? "なし")")
                    case .failure(let error):
                        if let afError = error.asAFError {
                            switch afError {
                            case .responseValidationFailed(let reason):
                                if case .unacceptableStatusCode(let code) = reason {
                                    errorMessage = "ログインに失敗しました。ステータスコード: \(code)"
                                } else {
                                    errorMessage = "ログインに失敗しました: \(reason)"
                                }
                            default:
                                errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                            }
                        } else {
                            errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                        }
                    }
                }
            }
    }
}
