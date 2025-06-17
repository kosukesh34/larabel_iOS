import SwiftUI
import Alamofire

struct UserDataView: View {
    @State public var userData: [String: Any]
    @State private var errorMessage: String?
    @AppStorage("authToken") private var authToken: String?
    @State private var showSuccessAlert: Bool = false
    @State private var showErrorAlert: Bool = false
    
    private let editableFields: Set<String> = ["name", "address", "phoneNumber", "birthday"]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("ユーザーデータ")
                    .font(.system(size: 24, weight: .bold, design: .rounded))
                    .foregroundColor(.primary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, 20)
                    .padding(.horizontal)
                
                SectionView(title: "編集可能な情報") {
                    ForEach(userData.keys.filter { editableFields.contains($0) }.sorted(), id: \.self) { key in
                        if key == "birthday", let date = userData[key] as? Date {
                            EditableDatePicker(
                                label: key.capitalized,
                                selection: Binding(
                                    get: { (userData[key] as? Date) ?? Date() },
                                    set: { userData[key] = $0 }
                                )
                            )
                        } else if let value = userData[key] as? String {
                            EditableTextField(
                                label: key.capitalized,
                                text: Binding(
                                    get: { userData[key] as? String ?? "" },
                                    set: { userData[key] = $0 }
                                )
                            )
                        }
                    }
                }
                
                SectionView(title: "編集不可な情報") {
                    ForEach(userData.keys.filter { !editableFields.contains($0) }.sorted(), id: \.self) { key in
                        if let value = userData[key] {
                            ReadOnlyField(
                                label: key.capitalized,
                                value: String(describing: value)
                            )
                        }
                    }
                }
                
                Button(action: {
                    updateUserData()
                }) {
                    Text("更新")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 10))
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
                .padding(.horizontal)
                .padding(.top, 10)
                
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.red)
                        .padding(.horizontal)
                        .padding(.top, 10)
                }
            }
            .padding(.bottom, 20)
        }
        .background(Color(.systemGroupedBackground))
        .alert("成功", isPresented: $showSuccessAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("更新が正常に完了しました。")
        }
        .alert("エラー", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage ?? "不明なエラーが発生しました。")
        }
    }
    
    func updateUserData() {
        guard let authToken = authToken else {
            errorMessage = "認証トークンがありません。ログインしてください。"
            showErrorAlert = true
            return
        }
        guard let userId = userData["id"] else {
            errorMessage = "ユーザーIDが見つかりません。"
            showErrorAlert = true
            return
        }
        
        let baseURL = "http://172.20.10.2/api"
        let url = "\(baseURL)/users/\(userId)"
        
        var parameters: [String: Any] = [:]
        for field in editableFields {
            if let value = userData[field] {
                if field == "birthday", let date = value as? Date {
                    let formatter = DateFormatter()
                    formatter.dateFormat = "yyyy-MM-dd"
                    parameters[field] = formatter.string(from: date)
                } else {
                    parameters[field] = value
                }
            }
        }
        
        if let name = userData["name"] {
            parameters["name"] = name
        }
        if let email = userData["email"] {
            parameters["email"] = email
        }
        
        if let status = userData["status"] as? String {
            parameters["status"] = status
        } else {
            parameters["status"] = "active"
        }
        
        print("Sending request to: \(url)")
        print("Parameters: \(parameters)")
        
        AF.request(url,
                   method: .put,
                   parameters: parameters,
                   encoding: JSONEncoding.default,
                   headers: [
                    "Authorization": "Bearer \(authToken)",
                    "Content-Type": "application/json",
                    "Accept": "application/json"
                   ])
        .validate(statusCode: 200..<300)
        .responseJSON { response in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let data):
                    print("更新成功: \(data)")
                    errorMessage = nil
                    showSuccessAlert = true
                case .failure(let error):
                    print("更新エラー: \(error)")
                    if let data = response.data,
                       let errorString = String(data: data, encoding: .utf8) {
                        print("サーバーレスポンス: \(errorString)")
                        errorMessage = "更新に失敗しました: \(errorString)"
                    } else {
                        errorMessage = "更新に失敗しました: \(error.localizedDescription)"
                    }
                    showErrorAlert = true
                }
            }
        }
    }
}

struct SectionView<Content: View>: View {
    let title: String
    let content: Content

    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundColor(.primary)
                .padding(.horizontal)
            content
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        .padding(.horizontal)
    }
}

struct EditableTextField: View {
    let label: String
    @Binding var text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .accessibilityLabel("編集可能")
            }
            TextField("", text: $text)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue, lineWidth: 2)
                )
                .font(.system(size: 16, design: .rounded))
                .accessibilityLabel("\(label) (編集可能)")
        }
    }
}

struct EditableDatePicker: View {
    let label: String
    @Binding var selection: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "pencil")
                    .foregroundColor(.blue)
                    .accessibilityLabel("編集可能")
            }
            DatePicker(
                "",
                selection: $selection,
                displayedComponents: .date
            )
            .datePickerStyle(.compact)
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.blue, lineWidth: 2)
            )
            .accessibilityLabel("\(label) (編集可能)")
        }
    }
}

struct ReadOnlyField: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                Spacer()
                Image(systemName: "lock")
                    .foregroundColor(.gray)
                    .accessibilityLabel("編集不可")
            }
            Text(value)
                .font(.system(size: 16, design: .rounded))
                .foregroundColor(.gray)
                .padding()
                .background(Color(.systemGray5))
                .clipShape(RoundedRectangle(cornerRadius: 8))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                )
                .accessibilityLabel("\(label) (編集不可)")
        }
    }
}
