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
    
    private let domain = "https://api.openweathermap.org"
    private let dataVersionMethod = "/data/2.5"

    let currentWeatherMethod = "/weather?q="
    let forecastMethod = "/forecast?q="

    var params: Parameters = [
        "q": "",
        "mode": "JSON",
        "APPID": "c21154f65ac934ec1c3af7b754337205",
        "units": "metric"
    ]
    
    enum WeatherMethod {
        case currentWeather
        case forecast
        
        var path: String {
            switch self {
            case .currentWeather:
                return "/weather?"
            case .forecast:
                return "/forecast?"
            }
        }
    }
    
    func getObject<T:Decodable>(
        city: String,
        method: WeatherMethod,
        handler: @escaping (Swift.Result<T, Error>) -> Void) {
            params["q"] = city
            let resultURL = domain + dataVersionMethod + method.path
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
    
    func checkInternetConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}


