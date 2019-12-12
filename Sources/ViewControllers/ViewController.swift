//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import UIKit
import RealmSwift


class ViewController: UIViewController {
    
    var forecast = Forecast()
    var currentWeather = CurrentWeather()
    var daysForecast = [DayForecast]()
    
    let REUSE_ID = "cell"
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var weatherInCityLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var forecastNoticeLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        
        //получаем данные из базы Realm
        if let cacheRealmDB = DataBase.shared.realm.objects(Forecast.self).last {
            daysForecast = Array(cacheRealmDB.list)
        }
        
        forecastTableView.reloadData()
    }

    
    @IBAction func getForecastButton(_ sender: Any) {
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        
        //FIXME: выдать ошибку если, если нет ответа от сервера
        //FIXME: реализовать загрузку из кеша, причем загрузить в ту же таблицы последние запросы, дать возможность пользователю выбрать нужный город из запроса
        //FIXME: при старте сразу загрузить из кеша последний запрос
        
        if let city = cityTextField.text {
            APIServices.shared.getObject(cityName: city, domain: .domainForecast){
                [weak self](result: Forecast?, error: Error?) in
                    if let error = error {                        
                        //print("\(error)")
                    } else if let result = result {
                        //print("\(result)")
                        self?.updateForecast(from: result)
                    }
            }
            
            APIServices.shared.getObject(cityName: city, domain: .domainCurrentWeather){
                [weak self](result: CurrentWeather?, error: Error?) in
                    if let error = error {
                        //print("\(error)")
                        
                        //повторный запрос к серверу, чтобы получить нормальный код ошибки
                        APIServices.shared.getObject(cityName: city, domain: .domainCurrentWeather){
                            [weak self](result: CurrentWeatherError?, error: Error?) in
                                if let error = error {
                                    //print("\(error)")
                                } else if let result = result {
                                    //print("\(result)")
                                    self?.sendCurrentWeatherError(from: result)
                                }
                        }
                        
                    } else if let result = result {
                        //print("\(result)")
                        self?.updateCurrentWeather(from: result)
                    }
            }
        }
    }
    
    private func sendCurrentWeatherError(from result: CurrentWeatherError){
        if let message = result.message {
            weatherInCityLabel.isHidden = false
            weatherInCityLabel.text = message + " try again"
        }
        
    }
    
    private func updateForecast(from result: Forecast){
        forecast = result
        forecastTableView.isHidden = false
        forecastNoticeLabel.isHidden = false
        
        // получим массив и отфильтруем по полю dt_txt, чтобы оставить элементы, содержащие в каждом днем отметку 12:00:))
        let convertForecastListArray = Array(forecast.list)
        daysForecast = convertForecastListArray.filter{$0.dt_txt!.contains("12:00:00") }
        forecastNoticeLabel.text = "\(daysForecast.count) day weather forecast:"
        
        // сохранение в базу Realm
        // FIXME: реализовать очистку кеша по данным введëнным больше 5 раз назад
        DataBase.shared.realm.beginWrite()
        DataBase.shared.realm.add(result)
        //print(DataBase.shared.realm.configuration.fileURL) // подсмотреть путь до базы
        try! DataBase.shared.realm.commitWrite()
        
        forecastTableView.reloadData()
    }
    
    private func updateCurrentWeather(from result: CurrentWeather){
        currentWeather = result
        weatherInCityLabel.isHidden = false
        weatherInCityLabel.text = "Weather in \(currentWeather.name!):"
        
        //FIXME: сделать метод по получению картинки, рассинхозировать загрузку картинки, сохранить ярлык в кеш
        if let iconShortCut = currentWeather.weather.first?.icon {
            let photoUrl = URL(string: "https://openweathermap.org/img/wn/\(iconShortCut)@2x.png")
            if let data = try? Data(contentsOf: photoUrl!), let image = UIImage(data: data) {
               self.weatherIconImageView.image = image
            }
        }
        
        currentTemperatureLabel.isHidden = false
        currentTemperatureLabel.text = "\(convertKelvToCelsius(currentWeather.main?.temp)!)°C"
        
        DataBase.shared.realm.beginWrite()
        DataBase.shared.realm.add(result)
        try! DataBase.shared.realm.commitWrite()
        
    }
    
    
    
    private func convertKelvToCelsius (_ temp: RealmOptional<Double>?) -> Int? {
        guard let tempValue = temp?.value else {return nil}
        return Int(tempValue - 273.15)
        
    }
    
    
}
//MARK: -UITableViewDataSource, -UITableViewDelegate

extension ViewController: UITableViewDelegate, UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return daysForecast.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

     let cell = tableView.dequeueReusableCell(withIdentifier: REUSE_ID) as! ForecastTableViewCell
        let currentTemperature = convertKelvToCelsius(daysForecast[indexPath.row].main?.temp)
        cell.setTemperatureLabel("\(currentTemperature!)°C")
        cell.setDateLabel(daysForecast[indexPath.row].dt_txt)
        cell.setImage(daysForecast[indexPath.row].weather.first?.icon)
      
        return cell
    }
}
