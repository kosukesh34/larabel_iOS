//
//  appUserView.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//

import Foundation
import SwiftUI

struct AddUserView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var viewModel: UserViewModel
    @State private var name = ""
    @State private var email = ""
    
    var body: some View {
        NavigationView {
            Form {
                TextField("Name", text: $name)
                TextField("Email", text: $email)
            }
            .navigationTitle("Add User")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        viewModel.addUser(name: name, email: email)
                        dismiss()
                    }
                }
            }
        }
    }
}
