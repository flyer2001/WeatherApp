//
//  DayForecast.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 23.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

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
