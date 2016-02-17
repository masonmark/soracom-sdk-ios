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
                    if let value = response.result.value as? [String: String],
                        let apiKey = value["apiKey"],
                        let token = value["token"],
                        let operatorId = value["operatorId"]
                    {
                        // Mason 2016-02-16: PARSING AUTH RESULT ALWAYS FAILS
                        // This code never executes in my limited testing, 
                        // because value is always nil here.
                        //
                        // In lldb it looks like:
                        //
                        //    (lldb) po response.result.value as? [String: String]
                        //    nil
                        //
                        // ...even though `result` is a valid AlamoFire.Response (.Success) and
                        //
                        //    (lldb) po response.result.value as? NSDictionary
                        //
                        // ...prints something that looks valid.
                        //
                        // So it looks like the conditional type cast 
                        // to [String: String] always fails. I think probably 
                        // something changed in AlamoFire since original code was written?
                        // 
                        // End result is that app hangs at the login screen after login
                        // attempt (since the onSuccess?() call never happens) and just
                        // prints response.result.value) to console.

                        Router.token = token
                        Router.apiKey = apiKey
                        Router.operatorId = operatorId
                        onSuccess?()
                    } else {
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
