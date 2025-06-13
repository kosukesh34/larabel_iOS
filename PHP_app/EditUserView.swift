//
//  EditUserView.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//

import Foundation
import SwiftUI


struct EditUserView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserViewModel
    var user: User
    @State private var name: String
    @State private var email: String

    init(viewModel: UserViewModel, user: User) {
        self.viewModel = viewModel
        self.user = user
        _name = State(initialValue: user.name)
        _email = State(initialValue: user.email)
    }

    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            .navigationTitle("Edit User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.updateUser(id: user.id, name: name, email: email)
                        dismiss()
                    }
                }
            }
        }
    }
}
