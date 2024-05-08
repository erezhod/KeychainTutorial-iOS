//
//  KeychainError.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation

enum KeychainError: Error, LocalizedError {
    case invalidValue
    case duplicateItem
    case itemNotFound
    case status(OSStatus)
        
    init(status: OSStatus) {
        switch status {
        case errSecDuplicateItem:
            self = .duplicateItem
        case errSecItemNotFound:
            self = .itemNotFound
        default:
            self = .status(status)
        }
    }
    
    var errorDescription: String? {
        switch self {
        case .invalidValue:
            "The value you have provided or requested is invalid"
        case .duplicateItem:
            "The Keychain item you are trying to create already exists"
        case .itemNotFound:
            "Could not find the item you are looking for in the Keychain"
        case .status(let status):
            "Keychain error: \(status)"
        }
    }
}
