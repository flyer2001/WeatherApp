//
//  ForecastModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Realm
import RealmSwift

//дополнительное поле для хранения поискового запроса вместе с результатом запроса

class IndexForecast: Object, Decodable {

    @objc dynamic var cityKey: String
    @objc dynamic var forecast: Forecast?
    var timeStamp: RealmOptional<Int>
    
    override static func primaryKey() -> String {
      return "cityKey"
    }
    
    required init(cityKey: String, forecast: Forecast?, timeStamp: RealmOptional<Int>) {
        self.cityKey = cityKey
        self.forecast = forecast
        self.timeStamp = timeStamp
        super.init()
    }

    required init() {
        cityKey = ""
        forecast = Forecast()
        timeStamp = RealmOptional(0)
        super.init()
    }
    
}

//описание модели

class Forecast: Object, Decodable {
    
    @objc dynamic var cod: String?
    var message: RealmOptional<Int>
    var cnt: RealmOptional<Int>
    var list = List<DayForecast>()
    @objc dynamic var city: City?
    
    @objc dynamic var cityKey: String?
    
    override static func primaryKey() -> String {
        return "cityKey"
    }
    
    required init(cod: String?, message: RealmOptional<Int>, cnt: RealmOptional<Int>) {
        self.cod = cod
        self.message = message
        self.cnt = cnt
        super.init()
    }
    
    required init() {
        cod = ""
        message = RealmOptional(0)
        cnt = RealmOptional(0)
        super.init()
    }
}

class City: Object, Decodable {
    
    var id: RealmOptional<Int>
    @objc dynamic var name: String?
    @objc dynamic var coord: Coord?
    @objc dynamic var country: String?
    var population: RealmOptional<Int>
    var timezone: RealmOptional<Int>
    var sunrise: RealmOptional<Int>
    var sunset: RealmOptional<Int>
    
    override static func primaryKey() -> String {
        return "name"
    }

    required init(id: RealmOptional<Int>, name: String, country: String, population: RealmOptional<Int>, timezone: RealmOptional<Int>, sunrise: RealmOptional<Int>, sunset: RealmOptional<Int>) {
        self.id = id
        self.name = name
        self.country = country
        self.population = population
        self.timezone = timezone
        self.sunrise = sunrise
        self.sunset = sunset
    }
    
    required init() {
        id = RealmOptional(0)
        name = ""
        country = ""
        population = RealmOptional(0)
        timezone = RealmOptional(0)
        sunrise = RealmOptional(0)
        sunset = RealmOptional(0)
        super.init()
    }

}

class Coord: Object, Decodable {
    var lat: RealmOptional<Double>
    var lon: RealmOptional<Double>
    
    required init(lat: RealmOptional<Double>, lon: RealmOptional<Double>) {
        self.lat = lat
        self.lon = lon
        super.init()
    }
    
    required init() {
        lat = RealmOptional(0.0)
        lon = RealmOptional(0.0)
        super.init()
    }
}

class DayForecast: Object, Decodable {
 
    private enum CodingKeys : String, CodingKey {
        case dt
        case main
        case weather
        case clouds
        case wind
        case sys
        case dt_txt
    }
    
    var dt: RealmOptional<Int>
    @objc dynamic var main: Main?
    var weather = List<Weather>()
    @objc dynamic var clouds: Clouds?
    @objc dynamic var wind: Wind?
    @objc dynamic var sys: Sys?
    @objc dynamic var dt_txt: String?
    
    @objc dynamic var id: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
//    convenience init(dt: RealmOptional<Int>, dt_text: String) {
//        self.init()
//        self.dt = dt
//        self.dt_text = dt_text
//    }
    
//    required init(from decoder: Decoder) throws {
//        let container = try decoder.container(keyedBy: CodingKeys.self)
//        let dt = try container.decode(RealmOptional<Int>.self, forKey: .dt)
//        let main = try container.decode(Main.self, forKey: .main)
//        let weather = try container.decode(List<Weather>.self, forKey: .weather)
//        let clouds = try container.decode(Clouds.self, forKey: .clouds)
//        let wind = try container.decode(Wind.self, forKey: .wind)
//        let sys = try container.decode(Sys.self, forKey: .sys)
//        let dt_txt = try container.decode(String.self, forKey: .dt_txt)
//        self.dt = dt
//        self.main = main
//        self.weather = weather
//        self.clouds = clouds
//        self.wind = wind
//        self.sys = sys
//        self.dt_txt = dt_txt
//
//        super.init()
//    }
    
//    required init()
//    {
//        dt = RealmOptional(0)
//        super.init()
//    }
    
 
    required init(dt: RealmOptional<Int>, dt_txt: String, id: String) {
        self.id = id
        self.dt = dt
        self.dt_txt = dt_txt
        super.init()
    }

    required init() {
        dt = RealmOptional(0)
        dt_txt = ""
        super.init()
    }
    
}

class Main: Object, Decodable {
    var temp: RealmOptional<Double>
    var temp_min: RealmOptional<Double>
    var temp_max: RealmOptional<Double>
    var pressure: RealmOptional<Int>
    var sea_level: RealmOptional<Int>
    var grnd_level: RealmOptional<Int>
    var humidity: RealmOptional<Int>
    var temp_kf: RealmOptional<Double>

    required init(temp: RealmOptional<Double>, temp_min: RealmOptional<Double>, temp_max: RealmOptional<Double>, pressure: RealmOptional<Int>, sea_level: RealmOptional<Int>, grnd_level: RealmOptional<Int>, humidity: RealmOptional<Int>, temp_kf: RealmOptional<Double>) {
        self.temp = temp
        self.temp_min = temp_min
        self.temp_max = temp_max
        self.pressure = pressure
        self.sea_level = sea_level
        self.grnd_level = grnd_level
        self.humidity = humidity
        self.temp_kf = temp_kf
        super.init()
    }
    
    @objc dynamic var id: String?
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    required init() {
        temp = RealmOptional(0.0)
        temp_min = RealmOptional(0.0)
        temp_max = RealmOptional(0.0)
        pressure = RealmOptional(0)
        sea_level = RealmOptional(0)
        grnd_level = RealmOptional(0)
        humidity = RealmOptional(0)
        temp_kf = RealmOptional(0.0)
        super.init()
    }
    
}

class Weather: Object, Decodable {
    private enum CodingKeys : String, CodingKey {
        case id
        case main
        case desc = "description"
        case icon
    }

    var id: RealmOptional<Int>
    @objc dynamic var main: String?
    @objc dynamic var desc: String?
    @objc dynamic var icon: String?

    required init(id: RealmOptional<Int>, main: String, desc: String, icon: String) {
        self.id = id
        self.main = main
        self.desc = desc
        self.icon = icon
        super.init()
    }
    
    required init() {
        id = RealmOptional(0)
        main = ""
        desc = ""
        icon = ""
        super.init()
    }
    
}

class Clouds: Object, Decodable {
    var all: RealmOptional<Int>
    
    required init(all: RealmOptional<Int>) {
        self.all = all
        super.init()
    }
    
    required init() {
        all = RealmOptional(0)
        super.init()
    }
}

class Wind: Object, Decodable {
    var speed: RealmOptional<Double>
    var deg: RealmOptional<Int>
    
    required init(speed: RealmOptional<Double>, deg: RealmOptional<Int>) {
        self.deg = deg
        self.speed = speed
        super.init()
    }
    
    required init() {
        deg = RealmOptional(0)
        speed = RealmOptional(0.0)
        super.init()
    }
}

class Sys: Object, Decodable {
    @objc dynamic var pod: String?
    
    required init(pod: String) {
        self.pod = pod
        super.init()
    }
    
    required init() {
        pod = ""
        super.init()
    }
    
}
