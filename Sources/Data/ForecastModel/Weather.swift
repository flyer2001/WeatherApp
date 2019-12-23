//
//  Weather.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 23.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import Realm
import RealmSwift

class Weather: Object, Decodable {
    private enum CodingKeys : String, CodingKey {
        case main
        case desc = "description"
        case icon
    }

    @objc dynamic var main: String?
    @objc dynamic var desc: String?
    @objc dynamic var icon: String?

    required init() {
        super.init()
    }
}
