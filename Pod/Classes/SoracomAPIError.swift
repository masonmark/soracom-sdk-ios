// SoracomAPIError.swift Created by mason on 3/6/16. Copyright © 2016 Soracom, Inc. All rights reserved.

import Foundation


/// SoracomAPIError represents an error returned by the API, or (in a few limited cases) an error that occurred while attempting to interact with the API.

public struct SoracomAPIError {
    let errorCode: String
    let message: String
    
    init(errorCode: String?, message: String?) {
        self.errorCode = errorCode ?? "UNK0001" // copy what Go SDK does
        self.message   = message ?? "unknown error"
        // FIXME: Mason 2016-03-06: the Go SDK has one more field, messageArgs, which is used to compose the actual message string, but I haven't yet had time to make that work. (See: api_error.go)
    }    
}
