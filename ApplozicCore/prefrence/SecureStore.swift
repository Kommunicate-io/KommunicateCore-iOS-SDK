//
//  SecureStore.swift
//  Applozic
//
//  Created by Mukesh on 29/04/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

import Foundation
import Security

@objc public class SecureStore: NSObject {
    let secureStoreQueryable: SecureStoreQueryable

    @objc public init(secureStoreQueryable: SecureStoreQueryable) {
        self.secureStoreQueryable = secureStoreQueryable
    }

    @objc public func setValue(_ value: String, for userAccount: String) throws {
        guard let encodedPassword = value.data(using: .utf8) else {
            throw SecureStoreError.string2DataConversionError
        }

        var query = secureStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccount

        var status = SecItemCopyMatching(query as CFDictionary, nil)
        switch status {
        case errSecSuccess:
            var attributesToUpdate: [String: Any] = [:]
            attributesToUpdate[String(kSecValueData)] = encodedPassword

            status = SecItemUpdate(query as CFDictionary,
                                   attributesToUpdate as CFDictionary)
            if status != errSecSuccess {
                throw error(from: status)
            }
        case errSecItemNotFound:
            query[String(kSecValueData)] = encodedPassword

            status = SecItemAdd(query as CFDictionary, nil)
            if status != errSecSuccess {
                throw error(from: status)
            }
        default:
            throw error(from: status)
        }
    }

    @objc public func getValue(for userAccount: String) throws -> String {
        var query = secureStoreQueryable.query
        query[String(kSecMatchLimit)] = kSecMatchLimitOne
        query[String(kSecReturnAttributes)] = kCFBooleanTrue
        query[String(kSecReturnData)] = kCFBooleanTrue
        query[String(kSecAttrAccount)] = userAccount

        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, $0)
        }

        switch status {
        case errSecSuccess:
            guard
                let queriedItem = queryResult as? [String: Any],
                let passwordData = queriedItem[String(kSecValueData)] as? Data,
                let password = String(data: passwordData, encoding: .utf8)
                else {
                    throw SecureStoreError.data2StringConversionError
            }
            return password
        case errSecItemNotFound:
            throw SecureStoreError.unhandledError(message: "Not found")
        default:
            throw error(from: status)
        }
    }

    @objc public func removeValue(for userAccount: String) throws {
        var query = secureStoreQueryable.query
        query[String(kSecAttrAccount)] = userAccount

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

    @objc public func removeAllValues() throws {
        let query = secureStoreQueryable.query

        let status = SecItemDelete(query as CFDictionary)
        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw error(from: status)
        }
    }

    private func error(from status: OSStatus) -> SecureStoreError {
        var message: String
        if #available(iOS 11.3, *) {
            message = SecCopyErrorMessageString(status, nil) as String? ?? NSLocalizedString("Unhandled Error", comment: "")
        } else {
            message = NSLocalizedString("Unhandled Error with status: \(status)", comment: "")
        }
        return SecureStoreError.unhandledError(message: message)
    }
}

public enum SecureStoreError: Error {
    case string2DataConversionError
    case data2StringConversionError
    case unhandledError(message: String)
}

extension SecureStoreError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .string2DataConversionError:
            return NSLocalizedString("String to Data conversion error", comment: "")
        case .data2StringConversionError:
            return NSLocalizedString("Data to String conversion error", comment: "")
        case .unhandledError(let message):
            return NSLocalizedString(message, comment: "")
        }
    }
}

@objc public protocol SecureStoreQueryable {
    var query: [String: Any] { get }
}

@objc public class PasswordQueryable: NSObject {
    let service: String

    @objc public init(service: String) {
        self.service = service
    }
}

extension PasswordQueryable: SecureStoreQueryable {
    public var query: [String: Any] {
        var query: [String: Any] = [:]
        query[String(kSecClass)] = kSecClassGenericPassword
        query[String(kSecAttrService)] = service
        return query
    }
}
