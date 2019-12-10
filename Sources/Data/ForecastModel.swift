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
    var cnt: Int?
    var list = List<DayForecast>()
    var city: City?
    
    required init(cod: String, message: Int, cnt: Int) {
        self.cod = cod
        self.message = message
        self.cnt = cnt
        super.init()
    }
    
    required init() {
        cod = ""
        message = 0
        cnt = 0
        super.init()
    }
}

class City: Object, Decodable {
    var id: Int?
    @objc dynamic var name: String?
    var coord: Coord?
    @objc dynamic var country: String?
    var population: Int?
    var timezone: Int?
    var sunrise: Int?
    var sunset: Int?

    required init(id: Int, name: String, country: String, population: Int, timezone: Int, sunrise: Int, sunset: Int) {
        self.id = id
        self.name = name
        self.country = country
        self.population = population
        self.timezone = timezone
        self.sunrise = sunrise
        self.sunset = sunset
    }
    
    required init() {
        id = 0
        name = ""
        country = ""
        population = 0
        timezone = 0
        sunrise = 0
        sunset = 0
        super.init()
    }

}

class Coord: Object, Decodable {
    var lat: Double?
    var lon: Double?
    
    required init(lat: Double, lon: Double) {
        self.lat = lat
        self.lon = lon
        super.init()
    }
    
    required init() {
        lat = 0.0
        lon = 0.0
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
    
    var dt: Int?
    
    var main: Main?
    var weather = List<Weather>()
    var clouds: Clouds?
    var wind: Wind?
    var sys: Sys?
    
    @objc dynamic var dt_txt: String?
    
    required init(dt: Int, dt_txt: String) {
        self.dt = dt
        self.dt_txt = dt_txt
        super.init()
    }
    
    required init() {
        dt = 0
        dt_txt = ""
        super.init()
    }
    
}

class Main: Object, Decodable {
    var temp: Double?
    var temp_min: Double?
    var temp_max: Double?
    var pressure: Double?
    var sea_level: Double?
    var grnd_level: Double?
    var humidity: Double?
    var temp_kf: Double?

    required init(temp: Double, temp_min: Double, temp_max: Double, pressure: Double, sea_level: Double, grnd_level: Double, humidity: Double, temp_kf: Double) {
        self.temp = temp
        self.temp_min = temp_min
        self.pressure = pressure
        self.sea_level = sea_level
        self.grnd_level = grnd_level
        self.humidity = humidity
        self.temp_kf = temp_kf
        super.init()
    }
    
    required init() {
        temp = 0.0
        temp_min = 0.0
        pressure = 0.0
        sea_level = 0.0
        grnd_level = 0.0
        humidity = 0.0
        temp_kf = 0.0
        super.init()
    }
    
}

class Weather: Object, Decodable {
    var id: Int?
    @objc dynamic var main: String?
    @objc dynamic var desc: String?
    @objc dynamic var icon: String?

    required init(id: Int, main: String, desc: String, icon: String) {
        self.id = id
        self.main = main
        self.desc = desc
        self.icon = icon
        super.init()
    }
    
    required init() {
        id = 0
        main = ""
        desc = ""
        icon = ""
        super.init()
    }
    
}

class Clouds: Object, Decodable {
    var all: Int?
    
    required init(all: Int) {
        self.all = all
        super.init()
    }
    
    required init() {
        all = 0
        super.init()
    }
}

class Wind: Object, Decodable {
    var speed: Double?
    var deg: Int?
    
    required init(speed: Double, deg: Int) {
        self.deg = deg
        self.speed = speed
        super.init()
    }
    
    required init() {
        deg = 0
        speed = 0.0
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
