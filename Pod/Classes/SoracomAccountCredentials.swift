// SoracomAccountCredentials.swift Created by mason on 2016-02-21. Copyright © 2016 Soracom, Inc. All rights reserved.

import Foundation


/// Simple object to represent a set of Soracom credentials (either a Soracom root acccount, SAM user, or AuthKey pair), that can read/write to/from persistent storage (Keychain).

public class SoracomAccountCredentials {
    var type          = SoracomAccountCredentialType.RootAccount
    var emailAddress  = ""
    var operatorID    = ""
    var username      = ""
    var password      = ""
    var authKeyID     = ""
    var authKeySecret = ""
    
    
    init(type: SoracomAccountCredentialType = .RootAccount, emailAddress: String = "", operatorID: String = "", username: String = "", password: String = "", authKeyID: String = "", authKeySecret: String = "") {
        self.type          = type
        self.emailAddress  = emailAddress
        self.operatorID    = operatorID
        self.username      = username
        self.password      = password
        self.authKeyID     = authKeyID
        self.authKeySecret = password
    }
    
    
    init(withDictionary dictionary: Dictionary<String, String>) {
        
        if let typeName = dictionary[kType], validType = SoracomAccountCredentialType(rawValue: typeName) {
            self.type = validType
        }
        
        emailAddress  = dictionary[kEmailAddress] ?? ""
        operatorID    = dictionary[kOperatorId] ?? ""
        username      = dictionary[kUsername] ?? ""
        password      = dictionary[kPassword] ?? ""
        authKeyID     = dictionary[kAuthKeyID] ?? ""
        authKeySecret = dictionary[kAuthKeySecret] ?? ""
    }
    
    
    convenience init(withKeychain: Bool, type: SoracomAccountCredentialType = .RootAccount, key: String = kKeychainItem) {
        if let data = Keychain.read(key), let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:String] {
            self.init(withDictionary: dict)
        } else {
            self.init(type: type)
        }
    }
    
    
    func dictionaryRepresentation() -> [String:String] {
        return [
            kType          : type.rawValue,
            kEmailAddress  : emailAddress,
            kOperatorId    : operatorID,
            kUsername      : username,
            kPassword      : password,
            kAuthKeyID     : authKeyID,
            kAuthKeySecret : authKeySecret,
            
            kAccountCredentialsStorageFormatVersion: "1"
        ]
    }
    
    // Write the credentials to the Keychain. (Currently only one set of credentials is supported, and this always overwrites any previously-saved credentials.
    
    func storeInKeychain(key: String = kKeychainItem) -> Bool {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionaryRepresentation())
        return Keychain.write(key, data: data)
    }
    
}


/// Define the different types of authentication. (see: https://dev.soracom.io/jp/docs/api/#!/Auth/auth )

enum SoracomAccountCredentialType: String {
    case RootAccount, SAM, AuthKey
}


private let kType         = "type"
private let kEmailAddress = "emailAddress"
private let kOperatorId   = "operatorID"
private let kUsername     = "username"
private let kPassword     = "password"
private let kAuthKeyID     = "authKeyID"
private let kAuthKeySecret     = "authKeySecret"

private let kKeychainItem = "jp.soracom.Soracom.storedCredentials"

private let kAccountCredentialsStorageFormatVersion = "accountCredentialsStorageFormatVersion"
// Swift's "private globals" seem the most convenient way to make constants like this, especially when they have to be used from initializers (no warnings about accessing self too early)... but I actually am still not sure what I think of this. Maybe using a private struct to get something like Keys.Type would be better?
