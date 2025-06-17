import SwiftUI
import Alamofire

struct SettingsView: View {
    @State private var scannedCode: String = ""
    @State private var message: String?
    @State private var isScanning = false
    @State private var pointsInput: String = "" // Input for points
    @AppStorage("authToken") private var authToken: String?

    var body: some View {
        VStack(spacing: 20) {
            Text("バーコードスキャン")
                .font(.largeTitle)
                .padding()

            // メッセージの表示
            if let message = message {
                Text(message)
                    .foregroundColor(.blue)
                    .padding()
            }

            // スキャナー表示またはスキャンボタン
            if isScanning {
                BarcodeScannerView(scannedCode: $scannedCode, isScanning: $isScanning)
                    .frame(height: 300)
            } else {
                Button("バーコードを読み取る") {
                    isScanning = true
                    message = nil
                }
                .padding()
                .background(Color.green)
                .foregroundColor(.white)
                .cornerRadius(10)
            }

            // スキャン結果とポイント入力
            if !scannedCode.isEmpty {
                Text("読み取り結果: \(scannedCode)")
                    .padding()

                // ポイント入力フィールド
                TextField("付与/使用するポイント数を入力", text: $pointsInput)
                    .keyboardType(.numberPad) // 数字入力用キーボード
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()
                    .onChange(of: pointsInput) { newValue in
                        // 入力が数字のみであることを保証
                        pointsInput = newValue.filter { $0.isNumber }
                    }

                HStack {
                    Button("ポイントを付与") {
                        sendPointRequest(endpoint: "add")
                    }
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(pointsInput.isEmpty || Int(pointsInput) == nil) // 無効化条件

                    Button("ポイントを使用") {
                        sendPointRequest(endpoint: "use")
                    }
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .disabled(pointsInput.isEmpty || Int(pointsInput) == nil) // 無効化条件
                }
            }
        }
        .padding()
    }

    func sendPointRequest(endpoint: String) {
        guard let token = authToken else {
            message = "認証トークンがありません"
            return
        }

        // ポイント入力のバリデーション
        guard let points = Int(pointsInput), points > 0 else {
            message = "有効なポイント数を入力してください"
            return
        }

        let url = "http://192.168.0.155/api/points/\(endpoint)"
        let parameters: [String: Any] = [
            "point_id": scannedCode,
            "point": points, // ユーザーが入力したポイント数を送信
            "shop": "SwiftUI店舗"
        ]

        AF.request(url,
                   method: .post,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: [
                       "Authorization": "Bearer \(token)",
                       "Content-Type": "application/json"
                   ])
            .validate(statusCode: 200..<300)
            .responseJSON { response in
                switch response.result {
                case .success(let value):
                    print("成功: \(value)")
                    message = "ポイント \(endpoint == "add" ? "付与" : "使用") に成功しました (\(points)ポイント)"
                case .failure(let error):
                    if let data = response.data,
                       let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
                       let errorMessage = json["message"] as? String,
                       let errors = json["errors"] as? [String: Any] {
                        print("サーバーエラー: \(errorMessage), 詳細: \(errors)")
                        message = "エラーが発生しました: \(errorMessage)"
                    } else {
                        print("エラー: \(error)")
                        message = "エラーが発生しました: \(error.localizedDescription)"
                    }
                }
            }
    }
}
