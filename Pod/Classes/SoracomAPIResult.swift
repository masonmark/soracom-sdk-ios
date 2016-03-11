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
    
    init(request: APIRequest, response: NSHTTPURLResponse?, data: NSData? = nil) {
        self.request  = request
        self.response = response
        self.data     = data
        
        APIError = getErrorIfHTTPStatusIsUnexpected() ?? getErrorIfExpectedKeysAreMissing()
    }
    
    /// The originating `APIRequest` instance, for which the receiver is a matched pair. The request has the details about what was requested and what the expectations were, while the result has the details of what actually came back from the sever (or what error occurred).
    let request: APIRequest
    
    /// The underlying system response object (which exposes some details like HTTP headers, HTTP version, etc). This object should always be present upon success, but may be nil when some kind of error has occurred.
    var response: NSHTTPURLResponse?
    
    /// The raw data received with the response.
    var data: NSData?
    
    /// Returns `self.data` as a UTF-8 string.
    var text: String? {
        return data != nil ? String(data: data!, encoding: NSUTF8StringEncoding) : nil
    }
    
    /// The actual HTTP status returned by the underlying HTTP request. May be nil, e.g. if error happened before HTTP response was received.
    var HTTPStatus: Int? {
        return response?.statusCode
    }
    
    /// The payload (the JSON payload converted to native dictionary).
    var payload: Dictionary<String, JSON>? {
        return data != nil ? JSON(data: data!).dictionaryValue : nil
    }
    
    /// If the API returns an error, it will be stored in this property.
    var APIError: SoracomAPIError?
    
    /// If an error occurs other than an API error, it will be stored in this property. (E.g.: "network not accessible" error)
    var clientError: NSError?
    
    /// Returns `true` if error occurred (in which case you should check `APIError` and `clientError` to get the error -- it could be either one).
    var hasError: Bool {
        return APIError != nil || clientError != nil
    }
    
    /// Returns a value from the API response payload, or nil if not present.
    subscript(key: String) -> JSON? {
        return payload?[key]
    }
    
    /// Internal func to compare the actual `HTTPStatus` with the `expectedHTTPStatus`, and construct and return an appropriate `SoracomAPIError` if they don't match. Returns nil if `HTTPStatus == expectedHTTPStatus`.
    func getErrorIfHTTPStatusIsUnexpected() -> SoracomAPIError? {
        guard HTTPStatus != request.expectedHTTPStatus else {
            return nil
        }
        
        // The API reported an error. Let's see if we can parse this as a regular API error response:
        let c = self["code"]?.stringValue
        let m = self["message"]?.stringValue
        
        if c != nil {
            return SoracomAPIError(errorCode: c, message: m)
        } else {
            // Hmm. The server didn't return the [code:, message:] err result that we understand, so make a generic error instead:
            return SoracomAPIError(errorCode: "CLI0666", message: "got HTTP status \(HTTPStatus), but expected \(request.expectedHTTPStatus)")
            // FIXME: See if we can add real err codes for client-side errs, that don't potentially conflict with API-side err codes.
        }
    }
    
    /// Internal func to check for missing keys and return an appropriate SoracomAPIError if required keys are missing. Returns nil if no keys are missing.
    func getErrorIfExpectedKeysAreMissing() -> SoracomAPIError? {
        var missingKeys: [String] = []
        for key in request.expectedResponseKeys {
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
