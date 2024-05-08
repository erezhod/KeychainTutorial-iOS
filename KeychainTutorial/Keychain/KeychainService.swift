//
//  KeychainService.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation
import Security

extension CFDictionary: @unchecked Sendable {}

struct KeychainService: Sendable {
    enum KeychainContainer: String {
        case `default` = "my_keychain_container"
    }
    
    private let container: KeychainContainer
    private let queue = DispatchQueue(label: "com.keychain.service.queue", attributes: .concurrent)

    init(container: KeychainContainer) {
        self.container = container
    }
    
    func getItem<T: Decodable>(forKey key: String, class: KeychainItemClass) async throws -> T? {
        let query = [
            kSecClass: `class`.rawValue,
            kSecAttrService: container.rawValue,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        
        let result = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<(data: Data?, status: OSStatus), Error>) in
            queue.async {
                var keychainObject: AnyObject?
                let status = SecItemCopyMatching(query, &keychainObject)

                guard status == errSecSuccess else {
                    if status == errSecItemNotFound {
                        continuation.resume(returning: (nil, status))
                    } else {
                        continuation.resume(throwing: KeychainError(status: status))
                    }
                    return
                }

                guard let data = keychainObject as? Data else {
                    continuation.resume(throwing: KeychainError.invalidValue)
                    return
                }
                
                continuation.resume(returning: (data, status))
            }
        }
        
        guard let data = result.data else {
            return nil
        }
        
        return try JSONDecoder().decode(T.self, from: data)
    }

    func setItem(_ value: some Encodable, forKey key: String, class: KeychainItemClass) async throws {
        let data = try JSONEncoder().encode(value)

        let query = [
            kSecClass: `class`.rawValue,
            kSecAttrService: container.rawValue,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                let status = SecItemAdd(query, nil)
                
                guard status == errSecSuccess else {
                    continuation.resume(throwing: KeychainError(status: status))
                    return
                }
                
                continuation.resume()
            }
        }
    }

    func updateItem(_ value: some Encodable, forKey key: String, class: KeychainItemClass) async throws {
        let data = try JSONEncoder().encode(value)

        let query = [
            kSecClass: `class`.rawValue,
            kSecAttrService: container.rawValue,
            kSecAttrAccount: key,
        ] as CFDictionary

        let updateAttributes = [
            kSecValueData: data
        ] as CFDictionary
        
        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                let status = SecItemUpdate(query, updateAttributes)
                
                guard status == errSecSuccess else {
                    continuation.resume(throwing: KeychainError(status: status))
                    return
                }
                
                continuation.resume()
            }
        }
    }

    func deleteItem(forKey key: String, class: KeychainItemClass) async throws {
        let query = [
            kSecClass: `class`.rawValue,
            kSecAttrService: container.rawValue,
            kSecAttrAccount: key
        ] as CFDictionary

        try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
            queue.async {
                let status = SecItemDelete(query)
                
                guard status == errSecSuccess else {
                    continuation.resume(throwing: KeychainError(status: status))
                    return
                }
                
                guard status == errSecSuccess else {
                    if status == errSecItemNotFound {
                        continuation.resume()
                    } else {
                        continuation.resume(throwing: KeychainError(status: status))
                    }
                    return
                }
                
                continuation.resume()
            }
        }
    }
}
