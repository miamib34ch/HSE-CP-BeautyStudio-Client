//
//  AuthTokenStorage.swift
//  HSE-CP-Client
//
//  Created by Богдан Полыгалов on 20.03.2023.
//

import Foundation
import SwiftKeychainWrapper

final class AuthStorage {
    private let keychain = KeychainWrapper.standard
    private let keyToken = "token"
    private let keyRole = "role"
    private let keyLogin = "login"

    var token: String? {
        get {
            return keychain.string(forKey: keyToken)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: keyToken)
        }
    }

    var role: String? {
        get {
            return keychain.string(forKey: keyRole)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: keyRole)
        }
    }

    var login: String? {
        get {
            return keychain.string(forKey: keyLogin)
        }
        set {
            guard let newValue = newValue else { return }
            keychain.set(newValue, forKey: keyLogin)
        }
    }

    func delete() {
        keychain.removeObject(forKey: keyToken)
        keychain.removeObject(forKey: keyRole)
    }
}
