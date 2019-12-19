//
//  APIServices.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Alamofire

final public class APIServices {
    
    public static let shared = APIServices()
    
    private let domain = "api.openweather.org"
    private let keyAPI = "c21154f65ac934ec1c3af7b754337205" // ключ, полученный на сайте owm
    private let  parsingMode = "json"
    
    //используются 2 API для текущей погоды и прогноза погоды
    enum Domain {
        case domainCurrentWeather
        case domainForecast
        
        var address: String {
            switch self {
            case .domainCurrentWeather:
                return "https://api.openweathermap.org/data/2.5/weather?"
            case .domainForecast:
                return "https://api.openweathermap.org/data/2.5/forecast?"
            }
        }
    }
    
    func getObject<T:Decodable>(
        domain: String,
        params: Parameters,
        handler: @escaping (_ object: T?, _ error: Error?) -> Void) {
            request(domain, method: .get, parameters: params).responseData(){ response in
                response.result.withValue { data in
                    do {
                        let result = try JSONDecoder.init().decode(T.self, from: data)
                        handler(result, nil)
                    } catch (let error) {
                        handler(nil, error)
                    }
                }.withError { error in
                    handler(nil, error)
                }
        }
    }
    
    func checkInternetConnection() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}
