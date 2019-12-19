//
//  ErrorModel.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 19.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import Foundation
import RealmSwift

class CurrentWeatherError: Object, Error, Decodable {
    
    @objc dynamic var cod: String?
    @objc dynamic var message: String?
    
    required init(cod: String?, message: String?) {
        self.cod = cod
        self.message = message
        super.init()
    }
    
    required init() {
        cod = ""
        message = ""
        super.init()
    }
    
}
