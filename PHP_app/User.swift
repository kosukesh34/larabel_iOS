//
//  User.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//


// User.swift
import Foundation

struct User: Codable, Identifiable {
    let id: Int
    var name: String
    var email: String
    let emailVerifiedAt: String?
    let createdAt: String
    let updatedAt: String
    
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case email
        case emailVerifiedAt = "email_verified_at"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }
}
