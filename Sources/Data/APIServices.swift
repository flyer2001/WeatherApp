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
    
    private let keyAPI = "c21154f65ac934ec1c3af7b754337205" // ключ, полученный на сайте owm
    private let  parsingMode = "json"
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
        cityName: String,
        domain: Domain,
        handler: @escaping (_ object: T?, _ error: Error?) -> Void) {
        let citiNameWithoutSpaces = cityName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        let resultURL = "\(domain.address)q=\(citiNameWithoutSpaces!)&mode=\(parsingMode)&APPID=\(keyAPI)"  //FIXME: сделать красивый конструктор URL со всеми параметрами
            request(resultURL).responseData(){ response in
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
    
}
