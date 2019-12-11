//
//  ForecastTableViewCell.swift
//  weatherApp
//
//  Created by Sergey Popyvanov on 11.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import UIKit

class ForecastTableViewCell: UITableViewCell {

    @IBOutlet weak var cellLabel: UILabel!
    @IBOutlet weak var dateCellLabel: UILabel!
    @IBOutlet weak var forecastIconImageView: UIImageView!
    
    func setTemperatureLabel(_ temperatureString: String?) {
        cellLabel.text = temperatureString
    }
    
    func setDateLabel(_ inputDate: String?) {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "MMM dd"
        if let date = dateFormatterGet.date(from: inputDate ?? "") {
            dateCellLabel.text = dateFormatterPrint.string(from: date)
        } else {
            print("There was an error decoding the string")
        }
        
        
    }
    
    func setImage(_ iconShorcut: String?) {
     if let shortCut = iconShorcut {
         let photoUrl = URL(string: "https://openweathermap.org/img/wn/\(shortCut)@2x.png")
         if let data = try? Data(contentsOf: photoUrl!), let image = UIImage(data: data) {
            self.forecastIconImageView.image = image
         }
     }
        
        
    }


}
