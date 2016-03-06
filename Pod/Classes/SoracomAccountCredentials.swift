// SoracomAccountCredentials.swift Created by mason on 2016-02-21. Copyright © 2016 Soracom, Inc. All rights reserved.

import Foundation


/// Simple object to represent a set of Soracom credentials (either for a Soracom root acccount, or SAM user), that can read/write to/from persistent storage (Keychain).

public class SoracomAccountCredentials {
    var type         = SoracomAccountCredentialType.RootAccount
    var emailAddress = ""
    var operatorID   = ""
    var username     = ""
    var password     = ""
    
    
    init(type: SoracomAccountCredentialType = .RootAccount, emailAddress: String = "", operatorID: String = "", username: String = "", password: String = "") {
        self.type         = type
        self.emailAddress = emailAddress
        self.operatorID   = operatorID
        self.username     = username
        self.password     = password
    }
    
    
    init(withDictionary dictionary: Dictionary<String, String>) {
        
        if let typeName = dictionary[kType], validType = SoracomAccountCredentialType(rawValue: typeName) {
            self.type = validType
        }
        
        emailAddress = dictionary[kEmailAddress] ?? ""
        operatorID   = dictionary[kOperatorId] ?? ""
        username     = dictionary[kUsername] ?? ""
        password     = dictionary[kPassword] ?? ""
    }
    
    
    convenience init(withKeychain: Bool) {
        if let data = Keychain.read(kKeychainItem), let dict = NSKeyedUnarchiver.unarchiveObjectWithData(data) as? [String:String] {
            self.init(withDictionary: dict)
        } else {
            log("WARNING: initialization from keychain failed")
            self.init()
        }
    }
    
    
    func dictionaryRepresentation() -> [String:String] {
        return [
            kType          : type.rawValue,
            kEmailAddress  : emailAddress,
            kOperatorId    : operatorID,
            kUsername      : username,
            kPassword      : password,
            kAccountCredentialsStorageFormatVersion: "1"
        ]
    }
    
    // Write the credentials to the Keychain. (Currently only one set of credentials is supported, and this always overwrites any previously-saved credentials.
    
    func storeInKeychain() {
        let data = NSKeyedArchiver.archivedDataWithRootObject(dictionaryRepresentation())
        Keychain.write(kKeychainItem, data: data)
    }
    
}


enum SoracomAccountCredentialType: String {
    case RootAccount, SAM //FIXME: Someday add .AuthKey (see: https://dev.soracom.io/jp/docs/api/#!/Auth/auth )
}


private let kType         = "type"
private let kEmailAddress = "emailAddress"
private let kOperatorId   = "operatorID"
private let kUsername     = "username"
private let kPassword     = "password"
private let kKeychainItem = "jp.soracom.Soracom.storedCredentials"
private let kAccountCredentialsStorageFormatVersion = "accountCredentialsStorageFormatVersion"
// Swift's "private globals" seem the most convenient way to make constants like this, especially when they have to be used from initializers (no warnings about accessing self too early)... but I actually am still not sure what I think of this. Maybe using a private struct to get something like Keys.Type would be better?
