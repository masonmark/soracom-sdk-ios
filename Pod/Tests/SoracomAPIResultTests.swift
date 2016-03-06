// SoracomAPIResultTests.swift Created by mason on 2016-03-06. Copyright © 2016 Soracom, Inc. All rights reserved.

import XCTest

class SoracomAPIResultTests: XCTestCase {
    
    func testMissingKeysErrorGeneration() {
        let payload = ["foo": "OK", "wat": "OMG"]
        let result1 = SoracomAPIResult(HTTPStatus: 200, payload: payload, expectedResponseKeys: ["foo", "bar", "baz"])
        
        XCTAssert(result1.hasError)
        XCTAssert(result1.APIError != nil)
        
        if let msg = result1.APIError?.message {
            XCTAssert(msg.containsString("bar, baz"))
            // because the message should list the missing keys
        } else {
            XCTFail("should have had message")
        }

        let result2 = SoracomAPIResult(HTTPStatus: 200, payload: payload, expectedResponseKeys: ["foo"])
        XCTAssert(!result2.hasError)
        XCTAssert(result2.APIError == nil)
    }
    
    
    func testBadHTTPStatusErrorGeneration() {
        let result1 = SoracomAPIResult(HTTPStatus: 500, payload: nil)
        XCTAssert(result1.hasError)
        XCTAssert(result1.APIError != nil)
        
        let result2 = SoracomAPIResult(HTTPStatus: 200, payload: nil)
        XCTAssert(!result2.hasError)
        XCTAssert(result2.APIError == nil)
    }

}
