//
//  Locker.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import Foundation

final class Locker {
    @KeychainItem(key: "api_token", class: .genericPassword)
    var apiToken: String?
}
