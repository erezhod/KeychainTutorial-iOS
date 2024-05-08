//
//  KeychainItemClass.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation
import Security

///A representation of a Keychain item class.
enum KeychainItemClass: RawRepresentable {
    /// Used for storing internet passwords, like login credentials for websites or Wi-Fi networks.
    case internetPassword
    /// For storing generic passwords, such as user authentication, encryption keys, or app-specific secrets.
    case genericPassword
    /// Represents X.509 certificates, used for secure communication over networks, like SSL/TLS certificates for websites.
    case certificate
    /// Stores cryptographic keys for encryption, decryption, digital signatures, and secure communication.
    case key
    /// Represents a combination of a cryptographic private key and its associated X.509 certificate, used for tasks like SSL/TLS client authentication and code signing.
    case identity
    
    init?(rawValue: CFString) {
        switch rawValue {
        case kSecClassInternetPassword:
            self = .internetPassword
        case kSecClassGenericPassword:
            self = .genericPassword
        case kSecClassCertificate:
            self = .certificate
        case kSecClassKey:
            self = .key
        case kSecClassIdentity:
            self = .identity
        default:
            return nil
        }
    }
    
    var rawValue: CFString {
        switch self {
        case .internetPassword:
            kSecClassInternetPassword
        case .genericPassword:
            kSecClassGenericPassword
        case .certificate:
            kSecClassGenericPassword
        case .key:
            kSecClassKey
        case .identity:
            kSecClassIdentity
        }
    }
    
}

