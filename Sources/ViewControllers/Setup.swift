//
//  Setup.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 19.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Alamofire

//Настройки приложения

let domain = "https://api.openweathermap.org"
let dataVersionMethod = "/data/2.5"

let currentWeatherMethod = "/weather?q="
let forecastMethod = "/forecast?q="

var params: Parameters = [
    "mode": "JSON",
    "APPID": "c21154f65ac934ec1c3af7b754337205",
    "units": "metric"
]

//        print(domain+dataVersionMethod+currentWeatherMethod)
//        params.updateValue("Samara", forKey: "q")
//        params.updateValue("Tumen", forKey: "q")
//        print(params)



