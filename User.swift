//
//  User.swift
//  PHP_app
//
//  Created by Kosuke Shigematsu on 6/13/25.
//


import Foundation

struct LoginResponse: Codable {
    let message: String
    let user: User?
    let token: String?
}

struct User: Codable {
    let id: Int
    let name: String
    let email: String
}

