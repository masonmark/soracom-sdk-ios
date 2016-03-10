import Foundation
import Alamofire

extension Soracom {
  
  public class func registerSubscriber(imsi: String, registrationSecret: String,  resultHandler: ((SoracomAPIResult) -> ()) ) {
    
    let requestValues = ["imsi": imsi, "registrationSecret": registrationSecret]
    
    Alamofire.request(Router.RegisterSubscriber(imsi, requestValues)).responseJSON { response in
      
      // Mason 2016-03-06: FIXME: This is temporary, experimental code!
      
      let HTTPStatus  = response.response?.statusCode
      let payload     = response.result.value as? Dictionary<String, AnyObject>
      var result      = SoracomAPIResult(HTTPStatus: HTTPStatus, payload: payload)
      
      print("Here is the REGISTER SUBSCRIBER レスポンス bro:")
      print(result)
      
      // Mason 2016-03-06: My experimentation has so far revealed different failure modes:
      
      if let error = response.result.error {
        // Failure mode 1: network offline, or other underlying Cocoa error occurred. In this case, response.response may be nil.
        result.clientError = error
      } else if result.hasError {
        // do nothing, err is already set
      } else {
        if let value = response.result.value as? NSDictionary {
          print("Registered subscriber successfully. (w00t w00t)")
          print(value)
        }
      }
      
      resultHandler(result)
    }
  }

  
  
    public class func subscribers(
        tagName: String? = nil,
        tagValue: String? = nil,
        tagValueMatchMode: TagValueMatchMode? = .Exact,
        statusFilter: Array<SubscriberStatus>? = nil,
        speedClassFilter: Array<SpeedClass>? = nil,
        limit: Int? = nil,
        lastEvaluatedKey: String? = nil,
        onSuccess: ((Array<Subscriber>) -> ())? = nil,
        onError: ((NSError) -> ())? = nil
        ) {
            var parameters: [String: AnyObject] = [:]
            if let tagName = tagName {
                parameters["tag_name"] = tagName
            }
            if let tagValue = tagValue {
                parameters["tag_value"] = tagValue
            }
            if let tagValueMatchMode = tagValueMatchMode {
                parameters["tag_value_match_mode"] = tagValueMatchMode.rawValue
            }
            if let statusFilter = statusFilter {
                parameters["status_filter"] = statusFilter.map { s in s.rawValue }.joinWithSeparator(",")
            }
            if let speedClassFilter = speedClassFilter {
                parameters["spped_class_filter"] = speedClassFilter.map { s in s.rawValue }.joinWithSeparator(",")
            }
            if let limit = limit {
                parameters["limit"] = limit
            }
            if let lastEvaluatedKey = lastEvaluatedKey {
                parameters["last_evaluated_key"] = lastEvaluatedKey
            }
            Alamofire.request(Router.Subscribers(parameters)).responseJSON { response in
                if let values = response.result.value as? [AnyObject] {
                    var subscribers = Array<Subscriber>()
                    for value in values {
                        if let value = value as? [String: AnyObject] {
                            let subscriber = Subscriber(value: value)
                            subscribers.append(subscriber)
                        } else {
                            debugPrint(value)
                        }
                    }
                    onSuccess?(subscribers)
                } else {
                    onError?(NSError(domain: "api.soracom.io", code: 1, userInfo: [:]))
                }
            }
    }

    public class func updateSpeedClass(
        imsi: String,
        newSpeedClass: SpeedClass,
        onSuccess: ((Subscriber) -> ())? = nil,
        onError: ((NSError) -> ())? = nil
        ) {
            let parameters: [String: AnyObject] = [ "speedClass" : newSpeedClass.rawValue ]
            Alamofire.request(Router.SubscriberUpdateSpeedClass(imsi, parameters)).responseJSON { response in
                if let value = response.result.value as? [String: AnyObject] {
                    let subscriber = Subscriber(value: value)
                    onSuccess?(subscriber)
                } else {
                    onError?(NSError(domain: "api.soraom.io", code: 1, userInfo: nil))
                }
            }
    }
}