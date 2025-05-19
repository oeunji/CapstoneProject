//
//  KeychainHelper.swift
//  CapstoneProject
//
//  Created by 이은지 on 5/9/25.
//

import Foundation
import Security

final class KeychainHelper {
    static let shared = KeychainHelper()

    private init() {}

    func save(_ value: String, forKey key: String) {
        let data = Data(value.utf8)

        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary
        SecItemDelete(query)

        let attributes = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecValueData: data
        ] as CFDictionary

        let status = SecItemAdd(attributes, nil)
        if status != errSecSuccess {
            print("🚨 Keychain 저장 실패")
        }
    }

    func retrieve(forKey key: String) -> String? {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key,
            kSecReturnData: true,
            kSecMatchLimit: kSecMatchLimitOne
        ] as CFDictionary

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query, &dataTypeRef)

        guard status == errSecSuccess, let data = dataTypeRef as? Data else {
            print("🚨 Keychain 불러오기 실패")
            return nil
        }

        return String(data: data, encoding: .utf8)
    }

    func delete(forKey key: String) {
        let query = [
            kSecClass: kSecClassGenericPassword,
            kSecAttrAccount: key
        ] as CFDictionary

        let status = SecItemDelete(query)
        if status != errSecSuccess {
            print("🚨 Keychain 삭제 실패")
        }
    }
}
