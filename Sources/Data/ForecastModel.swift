//
//  ForecastModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Realm
import RealmSwift

//описание модели для парсинга и хранения прогноза погоды на 5 дней

class Forecast: Object, Decodable {
    
    @objc dynamic var cod: String?
    var message: Int?
    //var cnt: Int?
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
        //fatalError("init() has not been implemented")
        super.init()
    }
}

class City: Object, Decodable {
    
    var id: Int?
    @objc dynamic var name: String?

    override static func primaryKey() -> String {
        return "name"
    }

    required init(id: Int, name: String) {
        self.id = id
        self.name = name
    }
    
    required init() {
        super.init()
    }
}

class DayForecast: Object, Decodable {
     
    var dt: RealmOptional<Int>
    @objc dynamic var main: Main?
    var weather = List<Weather>()
    @objc dynamic var dt_txt: String?
    
    @objc dynamic var id: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
 
    required init(dt: RealmOptional<Int>, dt_txt: String, id: String) {
        self.id = id
        self.dt = dt
        self.dt_txt = dt_txt
        super.init()
    }

    required init() {
        self.dt = RealmOptional(0)
        super.init()
    }
}

class Main: Object, Decodable {
    @objc dynamic var id: String?
    var temp: RealmOptional<Double>

    required init(temp: RealmOptional<Double>) {
        self.temp = temp
        super.init()
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required init() {
        self.temp = RealmOptional(0)
        super.init()
    }
}

class Weather: Object, Decodable {
    private enum CodingKeys : String, CodingKey {
//        case id
        case main
        case desc = "description"
        case icon
    }

    //var id: RealmOptional<Int>
    @objc dynamic var main: String?
    @objc dynamic var desc: String?
    @objc dynamic var icon: String?

    required init(main: String, desc: String, icon: String) {
       // self.id = id
        self.main = main
        self.desc = desc
        self.icon = icon
        super.init()
    }

    required init() {
        super.init()
    }
}
