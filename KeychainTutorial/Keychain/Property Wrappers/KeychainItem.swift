//
//  KeychainItem.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation

@propertyWrapper
final class KeychainItem<Value: Codable & Sendable>: Sendable {
    private let keychain: KeychainService
    private let key: String
    private let `class`: KeychainItemClass
    private let defaultValue: Value
    
    private var value: Value?
    
    init(key: String, class: KeychainItemClass, defaultValue: Value) {
        self.keychain = KeychainService(container: .default)
        self.key = key
        self.class = `class`
        self.defaultValue = defaultValue
    }

    var wrappedValue: Value {
        get {
            Task.synchronous { [unowned self] in
                do {
                    value = try await keychain.getItem(forKey: key, class: `class`)
                } catch let error as KeychainError {
                    print(error.errorDescription ?? "Keychain error occurred")
                } catch {
                    print(error.localizedDescription)
                }
            }
            return value ?? defaultValue
        }

        set {
            Task {
                do {
                    if let optional = newValue as? AnyOptional, optional.isNil {
                        try await keychain.deleteItem(forKey: key, class: `class`)
                    } else {
                        if let _: Value = try await keychain.getItem(forKey: key, class: `class`) {
                            try await keychain.updateItem(newValue, forKey: key, class: `class`)
                        } else {
                            try await keychain.setItem(newValue, forKey: key, class: `class`)
                        }
                    }
                } catch let error as KeychainError {
                    print(error.errorDescription ?? "Keychain error occurred")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
    }
}

extension KeychainItem where Value: ExpressibleByNilLiteral {
    /// Creates a new Keychain Item property wrapper for the given key.
    /// - Parameters:
    ///   - key: The key to use with the Keychain Item store.
    convenience init(key: String, class: KeychainItemClass) {
        self.init(key: key, class: `class`, defaultValue: nil)
    }
}
