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
    private let domain = "https://api.openweathermap.org/data/2.5/forecast?"
    
    public func getObject<T:Decodable>(
        cityName: String,
        handler: @escaping (_ object: T?, _ error: Error?) -> Void) {
       
        let resultURL = "\(domain)q=\(cityName)&mode=\(parsingMode)&APPID=\(keyAPI)"
        print(resultURL)
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
