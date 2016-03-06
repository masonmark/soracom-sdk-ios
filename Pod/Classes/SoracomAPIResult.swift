// SoracomAPIResult.swift reated by mason on 3/6/16. Copyright © 2016 Soracom, Inc. All rights reserved.

import Foundation


/// SoracomAPIResult represents the result of an API call, which is typically the response by the Soracom API server, but might instead be an error.
///
/// There are three basic failure modes:
/// - the API returns an error/failure
/// - the client app encountered a local error trying to access the API (e.g., network not available)
/// - the client failed to parse the response (indicating a bug in either the client or the API server)
///
/// If no error occurs, this object provides access to the response data from the API server.
///
/// This object also provides information about whether an error (of any of the types above) occurred, and provides access to the error. (A local error that causes a failure when trying to query the API is not, strictly speaking, an "API response", which is why this object is called an "API result" instead.)

public struct SoracomAPIResult {
    
    init(HTTPStatus: Int?, payload: Dictionary<String, AnyObject>?, expectedHTTPStatus: Int = 200, expectedResponseKeys: [String] = []) {
        self.HTTPStatus           = HTTPStatus
        self.payload              = payload
        self.expectedHTTPStatus   = expectedHTTPStatus
        self.expectedResponseKeys = expectedResponseKeys
        
        APIError = getErrorIfHTTPStatusIsUnexpected() ?? getErrorIfExpectedKeysAreMissing()
    }
    
    /// The HTTP status expected to be returned by the underlying HTTP request on success.
    let expectedHTTPStatus: Int
    
    /// The actual HTTP status returned by the underlying HTTP request.
    let HTTPStatus: Int?
    
    /// The payload (the JSON payload converted to native dictionary).
    let payload: Dictionary<String, AnyObject>?
    
    /// An array of keys indicating the values the response payload **must** have to be considered successful.
    let expectedResponseKeys: [String]
    
    /// If the API returns an error, it will be stored in this property.
    var APIError: SoracomAPIError?
    
    /// If an error occurs other than an API error, it will be stored in this property. (E.g.: "network not accessible" error)
    var clientError: NSError?
    
    /// Returns `true` if error occurred (in which case you should check `APIError` and `clientError` to get the error -- it could be either one).
    var hasError: Bool {
        return APIError != nil || clientError != nil
    }
    
    /// Returns a value from the API response payload, or nil if not present.
    subscript(key: String) -> AnyObject? {
        return payload?[key]
    }
    
    /// Internal func to compare the actual `HTTPStatus` with the `expectedHTTPStatus`, and construct and return an appropriate `SoracomAPIError` if they don't match. Returns nil if `HTTPStatus == expectedHTTPStatus`.
    func getErrorIfHTTPStatusIsUnexpected() -> SoracomAPIError? {
        guard HTTPStatus != expectedHTTPStatus else {
            return nil
        }
        
        // The API reported an error. Let's see if we can parse this as a regular API error response:
        let c = self["code"] as? String
        let m = self["message"] as? String
        
        if c != nil {
            return SoracomAPIError(errorCode: c, message: m)
        } else {
            // Hmm. The server didn't return the [code:, message:] err result that we understand, so make a generic error instead:
            return SoracomAPIError(errorCode: "CLI0666", message: "got HTTP status \(HTTPStatus), but expected \(expectedHTTPStatus)")
            // FIXME: See if we can add real err codes for client-side errs, that don't potentially conflict with API-side err codes.
        }
    }
    
    /// Internal func to check for missing keys and return an appropriate SoracomAPIError if required keys are missing. Returns nil if no keys are missing.
    func getErrorIfExpectedKeysAreMissing() -> SoracomAPIError? {
        var missingKeys: [String] = []
        for key in expectedResponseKeys {
            if payload?[key] == nil {
                missingKeys.append(key)
            }
        }
        if missingKeys.count > 0 {
            return SoracomAPIError(errorCode:"CLI0667", message: "failed to parse response: missing data for \(missingKeys.joinWithSeparator(", "))" )
        } else {
            return nil
        }
    }
    
}
