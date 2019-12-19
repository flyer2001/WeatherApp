//
//  CurrentWeatherModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 11.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation

import RealmSwift

class CurrentWeather: Object, Decodable {

    var cod: RealmOptional<Int>
    @objc dynamic var name: String?
    var weather = List<Weather>()
    @objc dynamic var main: MainCurrent?

    
    required init(cod: RealmOptional<Int>, name: String?) {
        self.cod = cod
        self.name = name
        super.init()
    }
    
    required init() {
        cod = RealmOptional(0)
        name = ""
        super.init()
    }
}

class MainCurrent: Object, Decodable {
    var temp: RealmOptional<Double>
    var temp_min: RealmOptional<Double>
    var temp_max: RealmOptional<Double>
    var pressure: RealmOptional<Int>
    var humidity: RealmOptional<Int>

    required init(temp: RealmOptional<Double>, temp_min: RealmOptional<Double>, temp_max: RealmOptional<Double>, pressure: RealmOptional<Int>, humidity: RealmOptional<Int>) {
        self.temp = temp
        self.temp_min = temp_min
        self.temp_max = temp_max
        self.pressure = pressure
        self.humidity = humidity
        super.init()
    }
    
    required init() {
        temp = RealmOptional(0.0)
        temp_min = RealmOptional(0.0)
        temp_max = RealmOptional(0.0)
        pressure = RealmOptional(0)
        humidity = RealmOptional(0)
        super.init()
    }
    
}

