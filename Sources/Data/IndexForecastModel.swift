//
//  ErrorModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 19.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import RealmSwift

// дополнительное поле для хранения поисковых запросов
class IndexForecast: Object, Decodable {

    @objc dynamic var cityKey: String
    @objc dynamic var forecast: Forecast?
    var timeStamp: RealmOptional<Int>
    
    override static func primaryKey() -> String {
      return "cityKey"
    }
    
    required init(cityKey: String, forecast: Forecast, timeStamp: RealmOptional<Int>) {
        self.cityKey = cityKey
        self.forecast = forecast
        self.timeStamp = timeStamp
        super.init()
    }
    
    required init() {
        cityKey = ""
        timeStamp = RealmOptional(0)
        super.init()
    }
    
}
