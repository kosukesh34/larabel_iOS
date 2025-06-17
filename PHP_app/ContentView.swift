import SwiftUI
import CoreImage.CIFilterBuiltins
import Alamofire

struct ContentView: View {
    @AppStorage("authToken") private var authToken: String?
    @State private var pointId: String? = nil
    @State private var userData: [String: Any]? = nil // ユーザーデータを保持
    @State private var errorMessage: String? = nil
    @State private var isLoading: Bool = false
    @State private var isShowingUserData: Bool = false // モーダル表示の状態

    var body: some View {
        VStack(spacing: 20) {
            Text("ようこそ！")
                .font(.largeTitle)

            // point_idのバーコード表示
            if let pointId = pointId {
                if let barcodeImage = generateBarcode(from: pointId) {
                    Image(uiImage: barcodeImage)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 100)
                        .padding()
                    Text("ポイントID: \(pointId)")
                        .font(.subheadline)
                } else {
                    Text("バーコードの生成に失敗しました")
                        .font(.headline)
                        .foregroundColor(.red)
                        .padding()
                }
            } else {
                Text("ポイントIDが取得できませんでした")
                    .font(.headline)
                    .foregroundColor(.gray)
                    .padding()
            }

            // ユーザーデータを表示するボタン
            Button(action: {
                isShowingUserData = true
            }) {
                Text("ユーザーデータを表示")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .sheet(isPresented: $isShowingUserData) {
                if let userData = userData {
                    UserDataView(userData: userData) // これが正常に動作する
                } else {
                    Text("ユーザーデータがありません")
                }
            }

            // エラーメッセージの表示
            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .font(.caption)
            }

            if isLoading {
                ProgressView()
            }

            Button("ログアウト") {
                authToken = nil
                pointId = nil
                userData = nil
            }
            .padding()
            .background(Color.red)
            .foregroundColor(.white)
            .cornerRadius(10)
        }
        .padding()
        .onAppear {
            fetchUserData()
        }
    }

    // ユーザーデータを取得する関数（Alamofireを使用）
    func fetchUserData() {
        isLoading = true
        errorMessage = nil
        pointId = nil
        userData = nil

        guard let token = authToken else {
            errorMessage = "トークンがありません"
            isLoading = false
            return
        }

        let url = "http://192.168.0.155/api/user"
        let headers: HTTPHeaders = [
            "Authorization": "Bearer \(token)"
        ]

        AF.request(url, method: .get, headers: headers).responseJSON { response in
            DispatchQueue.main.async {
                isLoading = false

                switch response.result {
                case .success(let value):
                    if let user = value as? [String: Any] {
                        userData = user // ユーザーデータを保存
                        if let pointIdFromResponse = user["point_id"] as? String {
                            pointId = pointIdFromResponse
                        } else {
                            errorMessage = "point_idがレスポンスに含まれていません"
                        }
                    } else {
                        errorMessage = "ユーザー情報の解析に失敗しました"
                    }
                case .failure(let error):
                    errorMessage = "エラーが発生しました: \(error.localizedDescription)"
                }
            }
        }
    }

    // バーコードを生成する関数
    func generateBarcode(from string: String) -> UIImage? {
        let filter = CIFilter.code128BarcodeGenerator()
        filter.message = Data(string.utf8)
        guard let outputImage = filter.outputImage else { return nil }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { return nil }
        return UIImage(cgImage: cgImage)
    }
}



