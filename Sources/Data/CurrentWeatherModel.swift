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

    var cod: Int?
    @objc dynamic var name: String?
    var weather = List<Weather>()
    @objc dynamic var main: MainCurrent?

    required init(cod: Int, name: String?) {
        self.cod = cod
        self.name = name
        super.init()
    }
    
    required init() {
        super.init()
    }
    
}

class MainCurrent: Object, Decodable {
    var temp: RealmOptional<Double>

    required init(temp: RealmOptional<Double>) {
        self.temp = temp
        super.init()
    }
    
    required init() {
        self.temp = RealmOptional(0)
        super.init()
    }
    
}

