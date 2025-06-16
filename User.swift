//
//  User.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//


import Foundation

// ログイン全体のレスポンス
struct LoginResponse: Codable {
    let message: String
    let user: User
    let token: String
}

// ユーザー情報
struct User: Codable {
    let id: Int
    let email: String
    let name: String?
    let address: String?
    let birthday: String?
    let phoneNumber: String?
    let pointId: String
    let status: String?
    let createdAt: String
    let updatedAt: String

   
    enum CodingKeys: String, CodingKey {
        case id
        case email
        case name
        case address
        case birthday
        case phoneNumber = "phone_number"
        case pointId = "point_id"
        case status
        case createdAt = "created_at"
        case updatedAt = "updated_at"      
    }
}
