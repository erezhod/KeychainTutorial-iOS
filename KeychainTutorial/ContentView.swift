//
//  ContentView.swift
//  KeychainTutorial
//
//  Created by Erez Hod on 8/5/24.
//

import SwiftUI

struct ContentView: View {
    private let keychainService = KeychainService(container: .default)
    private let locker = Locker()
    
    @State private var key: String = ""
    @State private var setValue: String = ""
    @State private var updateValue: String = ""
    @State private var getValue: String = ""
    
    @State private var showErrorAlert: Bool = false
    @State private var keychainError: KeychainError?
    
    var body: some View {
        NavigationStack {
            Form {
                Section("Property Wrapper") {
                    Button("Set PW", action: setPW)
                    Button("Get PW", action: getPW)
                    Button("Update PW", action: updatePW)
                    Button("Delete PW", action: deletePW)
                }
                
                Section("Set an item") {
                    TextField("Key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("Value", text: $setValue)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Set Item", action: setItem)
                }
                
                Section("Update an item") {
                    TextField("Existing Key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    TextField("New Value", text: $updateValue)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Update", action: updateItem)
                }
                
                Section("Get an item") {
                    TextField("Existing Key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    if !getValue.isEmpty {
                        Text(getValue)
                            .foregroundStyle(.gray)
                    }
                    
                    Button("Get", action: getItem)
                }
                
                Section("Delete an item") {
                    TextField("Existing Key", text: $key)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                    
                    Button("Delete", role: .destructive, action: deleteItem)
                }
            }
            .formStyle(.grouped)
            .navigationTitle(" Keychain")
            .navigationBarTitleDisplayMode(.large)
            .alert(isPresented: $showErrorAlert, error: keychainError) {
                Button("OK") {}
            }
        }
    }
    
    private func setItem() {
        if key.isEmpty || setValue.isEmpty { return }
        
        Task {
            do {
                try await keychainService.setItem(setValue, forKey: key, class: .genericPassword)
            } catch let error as KeychainError {
                showKeychainError(error: error)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func updateItem() {
        if key.isEmpty || updateValue.isEmpty { return }
        
        Task {
            do {
                try await keychainService.updateItem(updateValue, forKey: key, class: .genericPassword)
            } catch let error as KeychainError {
                showKeychainError(error: error)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func getItem() {
        if key.isEmpty { return }
        
        Task { @MainActor in
            do {
                let value: String? = try await keychainService.getItem(forKey: key, class: .genericPassword)
                getValue = value ?? "No value received for key \"\(key)\""
            } catch let error as KeychainError {
                showKeychainError(error: error)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func deleteItem() {
        Task {
            do {
                try await keychainService.deleteItem(forKey: key, class: .genericPassword)
                resetForm()
            } catch let error as KeychainError {
                showKeychainError(error: error)
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    private func showKeychainError(error: KeychainError) {
        keychainError = error
        showErrorAlert = true
    }
    
    private func resetForm() {
        key = ""
        setValue = ""
        updateValue = ""
        getValue = ""
    }
    
    private func setPW() {
        locker.apiToken = "abcd1234"
    }
    
    private func getPW() {
        let token = locker.apiToken ?? "NONE"
        print("Locker token: \(token)")
    }
    
    private func updatePW() {
        locker.apiToken = "Suzuki12t566"
    }
    
    private func deletePW() {
        locker.apiToken = nil
    }
}

#Preview {
    ContentView()
}
