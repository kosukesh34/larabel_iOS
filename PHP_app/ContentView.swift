import SwiftUI
struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()
    @State private var showingAddUser = false
    @State private var showingEditUser = false
    @State private var selectedUser: User?
    @State private var newName = ""
    @State private var newEmail = ""
    
    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.users) { user in
                    VStack(alignment: .leading) {
                        Text(user.name)
                            .font(.headline)
                        Text(user.email)
                            .font(.subheadline)
                    }
                    .contextMenu {
                        Button("Edit") {
                            selectedUser = user
                            newName = user.name
                            newEmail = user.email
                            showingEditUser = true
                        }
                        Button("Delete", role: .destructive) {
                            viewModel.deleteUser(id: user.id)
                        }
                    }
                }
            }
            .navigationTitle("Users")
            .toolbar {
                Button("Add User") {
                    showingAddUser = true
                }
            }
            .sheet(isPresented: $showingAddUser) {
                AddUserView(viewModel: viewModel)
            }
            .sheet(isPresented: $showingEditUser) {
                if let user = selectedUser {
                    EditUserView(viewModel: viewModel, user: user)
                }
            }
        }
        .onAppear {
            viewModel.fetchUsers()
        }
    }
}
