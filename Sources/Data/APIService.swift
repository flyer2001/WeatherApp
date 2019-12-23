//
//  APIServices.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Alamofire

final public class APIService {
    
    public static let shared = APIService()
    
    let sessionManager = SessionManager.default
    
    
    func getObject<T:Decodable>(
        
        
        domain: String,
        params: Parameters,
        handler: @escaping (_ object: T?, _ error: Error?, _ statusCode: Int?) -> Void) {
            request(domain, method: .get, parameters: params).responseData(){ response in
                let responseStatuseCode = response.response?.statusCode
                response.result.withValue { data in
                        do {
                            let result = try JSONDecoder.init().decode(T.self, from: data)
                            handler(result, nil, responseStatuseCode)
                        } catch (let error) {
                            handler(nil, error, responseStatuseCode)
                        }
                    }.withError { error in
                        handler(nil, error, responseStatuseCode)
                    }
        }
    }
    
    func checkInternetConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}


