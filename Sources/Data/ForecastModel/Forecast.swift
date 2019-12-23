//
//  ForecastModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Realm
import RealmSwift

class Forecast: Object, Decodable {
    
    @objc dynamic var cod: String?
    var message: Int?
    var list = List<DayForecast>()
    @objc dynamic var city: City?
    
    @objc dynamic var cityKey: String?
    
    override static func primaryKey() -> String {
        return "cityKey"
    }
    
    required init(cod: String, message: Int) {
        self.cod = cod
        self.message = message
        super.init()
    }
    
    required init() {
        super.init()
    }
}
