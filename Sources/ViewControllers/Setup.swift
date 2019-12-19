//
//  Setup.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 19.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Alamofire

//Настройки запросов для API

let domain = "https://api.openweathermap.org"
let dataVersionMethod = "/data/2.5"

let currentWeatherMethod = "/weather?q="
let forecastMethod = "/forecast?q="

var params: Parameters = [
    "mode": "JSON",
    "APPID": "c21154f65ac934ec1c3af7b754337205",
    "units": "metric"
]

let manager = Alamofire.SessionManager.default
let timeoutIntervalAPI = 3.0   // интервал по времени запроса для API, сек

let timeOutButtonInterval = 3  // интервал заморозки кнопки "Get Forecast"
