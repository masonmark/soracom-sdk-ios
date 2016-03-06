import Foundation
import Alamofire

extension Soracom {
    public class func auth(email: String,
        password: String,
        timeout: Int = 86400,
        onSuccess: (() -> ())? = nil,
        onError: ((NSError) -> ())? = nil) {
            Alamofire.request(Router.Auth(["email" : email, "password": password, "tokenTimeoutSeconds" : timeout])).responseJSON { response in
                if let error = response.result.error {
                    onError?(error)
                } else {
                  if let value = response.result.value as? NSDictionary,
                    apiKey     = value["apiKey"] as? String,
                    token      = value["token"] as? String,
                    operatorId = value["operatorId"] as? String
                  {
                        Router.token = token
                        Router.apiKey = apiKey
                        Router.operatorId = operatorId
                        onSuccess?()
                    } else {
                      // FIXME: Failures in auth() may not be reported correctly (Mason 2016-03-06)
                      // Need to report error here. At least one (and perhaps all?) errors will look like this:
                      //      (lldb) po response.result
                      //        ▿ SUCCESS: {
                      //          code = COM0008;
                      //          message = "Constraint vaiolation of input value. message:not a well-formed email address:email";
                      //      }
                      //
                      // So, either a.) the Soracom API is not returning an HTTP error, and instead returns an HTTP success response with the error expressed in the JSON structure, or b.) something else (haha).
                      //
                      // I'm in an airplane so it's not easy to check. Either way, though, we need to improve this function to reliably indicate error, and invoke onError(), in all error cases.

                        print(response.result.value)
                    }
                }
            }
    }

    public static var isLoggedIn: Bool {
        return Router.apiKey != nil
    }

    public static var operatorId: String? {
        return Router.operatorId
    }
}
