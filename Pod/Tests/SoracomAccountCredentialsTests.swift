// SoracomAccountCredentialsTests.swift Created by mason on 2016-02-21. Copyright © 2016 Soracom, Inc. All rights reserved.

import XCTest

class SoracomAccountCredentialsTests: XCTestCase {
    
    var one: SoracomAccountCredentials = SoracomAccountCredentials(type: .RootAccount, emailAddress: "one", operatorID: "one", username: "one", password: "one")
    
    var two: SoracomAccountCredentials = SoracomAccountCredentials(type: .SAM, emailAddress: "two", operatorID: "two", username: "two", password: "two")
    
    var funky = [
        "type"          : "w00t",
        "emailAddress"  : "w00t",
        "operatorID"    : "w00t",
        "username"      : "w00t",
        "password"      : "w00t"
    ]
    
    func test_storeInKeychain() {
        one.storeInKeychain()
        two = SoracomAccountCredentials(withKeychain: true)
        
        XCTAssert(two.type == one.type)
        XCTAssert(two.emailAddress == one.emailAddress)
        XCTAssert(two.operatorID == one.operatorID)
        XCTAssert(two.username == one.username)
        XCTAssert(two.password == one.password)
        
    }
    
    func test_serialization_roundtrip() {
        let d = one.dictionaryRepresentation()
        
        two = SoracomAccountCredentials.init(withDictionary: d)
        
        XCTAssert(two.type == one.type)
        XCTAssert(two.emailAddress == one.emailAddress)
        XCTAssert(two.operatorID == one.operatorID)
        XCTAssert(two.username == one.username)
        XCTAssert(two.password == one.password)
    }
    
    func test_deserialization() {
        let foo = SoracomAccountCredentials.init(withDictionary: funky)
        
        XCTAssert(foo.type == .RootAccount) // because bogus val should be ignored for this prop
        XCTAssert(foo.emailAddress == "w00t")
        XCTAssert(foo.operatorID == "w00t")
        XCTAssert(foo.username == "w00t")
        XCTAssert(foo.password == "w00t")
        
        let bar = SoracomAccountCredentials.init(withDictionary: [:])
        XCTAssert(bar.type == .RootAccount)
        XCTAssert(bar.emailAddress == "")
        XCTAssert(bar.operatorID == "")
        XCTAssert(bar.username == "")
        XCTAssert(bar.password == "")
    }
    
}
