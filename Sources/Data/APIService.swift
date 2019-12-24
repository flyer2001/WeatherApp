//
//  APIServices.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Alamofire

struct CustomError: Error, Decodable {
    let message: String?
    let code: String?
}

final public class APIService {
    
    public static let shared = APIService()
    
    let sessionManager = SessionManager.default
    
    func getObject<T:Decodable>(
        url: URL?,
        params: Parameters,
        handler: @escaping (Swift.Result<T, Error>) -> Void) {
        if let resultURL = url {
            request(resultURL, method: .get, parameters: params).responseData(){ response in
                    response.result.withValue { data in
                        do {
                            if let responseError = response.response?.statusCode {
                                if responseError != 200 {
                                        let error = try JSONDecoder.init().decode(CustomError.self, from: data)
                                        handler(.failure(error))
                                        return
                                    } else {
                                        let result = try JSONDecoder.init().decode(T.self, from: data)
                                        handler(.success(result))
                                        return
                                    }
                                }
                        } catch (let error) {
                            handler(.failure(error))
                            return
                        }
                    }.withError { error in
                        handler(.failure(error))
                    }
            }
        }

    }
    
    func checkInternetConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}


