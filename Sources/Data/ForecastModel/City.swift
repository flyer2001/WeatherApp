//
//  City.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 23.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Realm
import RealmSwift

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
