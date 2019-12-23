//
//  Main.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 23.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

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

