//
//  User Model.swift
//  CubStartFinal
//
//  Created by Hongyuan Kang on 11/28/23.
//

import Foundation
class UserManager {
    static let shared = UserManager()

    func createUser(username: String, password: String) {
        UserDefaults.standard.set(password, forKey: username)
    }

    func validateUser(username: String, password: String) -> Bool {
        let storedPassword = UserDefaults.standard.string(forKey: username)
        return password == storedPassword
    }
}
