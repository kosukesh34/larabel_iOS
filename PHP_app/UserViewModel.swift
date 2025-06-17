import Foundation

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    private let baseURL = "http://172.20.10.2/api/users"
    
    func fetchUsers() {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response: \(String(describing: response))")
                return
            }
            
            if let data = data {
                do {
                    let users = try JSONDecoder().decode([User].self, from: data)
                    DispatchQueue.main.async {
                        self?.users = users
                    }
                } catch {
                    print("Decoding error: \(error)")
                }
            }
        }.resume()
    }
    
    func addUser(name: String, email: String) {
        guard let url = URL(string: baseURL) else {
            print("Invalid URL")
            return
        }
        
        // Create a user dictionary matching the API's expected structure
        let user = [
            "name": name,
            "email": email,
            // Include additional fields if required by the API
            "password": "defaultPassword123", // Adjust as needed (e.g., API might require a password)
            "email_verified_at": nil, // Optional: include if API expects this
            "created_at": ISO8601DateFormatter().string(from: Date()), // Optional: include if API expects this
            "updated_at": ISO8601DateFormatter().string(from: Date())  // Optional: include if API expects this
        ] as [String: Any?]
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            // Filter out nil values and encode the user dictionary
            let filteredUser = user.compactMapValues { $0 }
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredUser)
        } catch {
            print("Encoding error: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                if let data = data, let errorMessage = String(data: data, encoding: .utf8) {
                    print("Server error: \(errorMessage)")
                } else {
                    print("Invalid response: \(String(describing: response))")
                }
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchUsers() // Refresh the user list after successful addition
            }
        }.resume()
    }
    
    func updateUser(id: Int, name: String, email: String) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            print("Invalid URL")
            return
        }
        
        let user = [
            "name": name,
            "email": email,
            "updated_at": ISO8601DateFormatter().string(from: Date()) // Optional: include if API expects this
        ] as [String: Any?]
        
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        do {
            let filteredUser = user.compactMapValues { $0 }
            request.httpBody = try JSONSerialization.data(withJSONObject: filteredUser)
        } catch {
            print("Encoding error: \(error)")
            return
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response: \(String(describing: response))")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchUsers()
            }
        }.resume()
    }
    
    func deleteUser(id: Int) {
        guard let url = URL(string: "\(baseURL)/\(id)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        URLSession.shared.dataTask(with: request) { [weak self] _, response, error in
            if let error = error {
                print("Network error: \(error.localizedDescription)")
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse, (200...299).contains(httpResponse.statusCode) else {
                print("Invalid response: \(String(describing: response))")
                return
            }
            
            DispatchQueue.main.async {
                self?.fetchUsers()
            }
        }.resume()
    }
}
