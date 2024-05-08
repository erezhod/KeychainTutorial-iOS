//
//  KeychainItem.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation

extension Task where Failure == Error {
    /// Performs an async task in a sync context.
    ///
    /// - Note: This function blocks the thread until the given operation is finished. The caller is responsible for managing multithreading.
    static func synchronous(priority: TaskPriority? = nil, operation: @escaping @Sendable () async throws -> Success) {
        let semaphore = DispatchSemaphore(value: 0)

        Task(priority: priority) {
            defer { semaphore.signal() }
            return try await operation()
        }

        semaphore.wait()
    }
}

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
                } catch {
                    print(error)
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
