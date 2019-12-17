//
//  ViewController.swift
//  WeatherApp
//
//  Created by Sergey Popyvanov on 10.12.2019.
//  Copyright © 2019 Sergey Popyvanov. All rights reserved.
//

import UIKit
import RealmSwift
import Alamofire
import iOSDropDown

class ViewController: UIViewController {
    //FIX: пофиксить констрейнты
    
    
    var forecast = Forecast()
    var currentWeather = CurrentWeather()
    var daysForecast = [DayForecast]()
    
    var networkReachabilityManager = Alamofire.NetworkReachabilityManager()
    
    let REUSE_ID = "cell"
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var weatherInCityLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var forecastNoticeLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var dropDownMenuOfSavedSearch: DropDown!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        
        dropDownMenuOfSavedSearch.text = "Choose"
        dropDownMenuOfSavedSearch.isSearchEnable = false
        dropDownMenuOfSavedSearch.optionArray = ["1", "2", "3", "4", "5"]
        //Проверяем есть ли интернет и в случае если нет запускаем Offline вариант с загрузкой из кеша
        checkOfflineMode()
        
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
        
        //Если поле нажатия кнопки нет Интернета, загрузить Offline Mode
        checkOfflineMode()
        
        if APIServices.shared.checkInternetConnection() == false {
            print("NO INTERNET")
        } else {
            if let city = cityTextField.text {
                APIServices.shared.getObject(cityName: city, domain: .domainForecast){
                    [weak self](result: Forecast?, error: Error?) in
                        if let error = error {
                            print("\(error)")
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
        
        //FIXME: реализовать загрузку из кеша, причем загрузить в ту же таблицы последние запросы, дать возможность пользователю выбрать нужный город из запроса
        //FIXME: при старте сразу загрузить из кеша последний запрос, отфильтрованный по дням
        
    }
    
    private func checkOfflineMode(){
        if APIServices.shared.checkInternetConnection() == false {
            print("NO INTERNET")
            weatherInCityLabel.isHidden = false
            weatherInCityLabel.text = "Check your internet connection"
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
   
        var savedObject = IndexForecast()
        
        var checkToUpdate: Results<Forecast>
        
        
        if let cityFromJSON = forecast.city?.name {
            savedObject = IndexForecast(cityKey: cityFromJSON, forecast: forecast)
            savedObject.forecast?.cityKey = cityFromJSON
            checkToUpdate = DataBase.shared.realm.objects(Forecast.self).filter("cityKey CONTAINS[c] '\(cityFromJSON)'")
            
            if checkToUpdate.count == 0 {
                if let dayForecastUpdate = savedObject.forecast?.list {
                    for dayForecast in dayForecastUpdate {
                        dayForecast.id = UUID().uuidString
                    }
                DataBase.shared.realm.beginWrite()
                DataBase.shared.realm.add(savedObject, update: .all)
                try! DataBase.shared.realm.commitWrite()
                }
            }
            
            //FIXME: реализовать генерацию нового айди для новых полей и фильтрацию по текущей дате, и может сделать общую функцию чтобы чистить реалм при старте на протухшие значения
//           else {
//                if let oldDayForecastConvert = Array(checkToUpdate).first {
//
//                    //FIXME: при отфильтровать все значения Forecast по полю dt, которые меньше текущего дня
//                    var oldDayForecast = [DayForecast]()
//                    for dayForecast in oldDayForecastConvert.list {
//                        oldDayForecast.append(dayForecast)
//                    }
//                    var newDayForecast = [DayForecast]()
//                    for dayForecast in forecast.list {
//                        newDayForecast.append(dayForecast)
//                    }
//                    // save old ID
//                    for newDayForecast in newDayForecast {
//                        for oldDayForecast in oldDayForecast {
//                            if newDayForecast.dt_txt == oldDayForecast.dt_txt {
//                                newDayForecast.id = oldDayForecast.id
//                            }
//                        }
//                    }
//                    let uniqueElementsDayForecast = Set(newDayForecast).subtracting(Set(oldDayForecast))
//
//                    // FIXME: найти новые уникальные значения и им сгенерировать ID
//                    for dayForecast in Array(uniqueElementsDayForecast) {
//
//                        //dayForecast.id = UUID().uuidString
//                    }
//                }
//
//            }
            
        }
        

        forecastTableView.isHidden = false
        forecastNoticeLabel.isHidden = false
        
        // получим массив и отфильтруем по полю dt_txt, чтобы оставить элементы, содержащие в каждом днем отметку 12:00
        let convertForecastListArray = Array(forecast.list)
        daysForecast = convertForecastListArray.filter{$0.dt_txt!.contains("12:00:00") }
        forecastNoticeLabel.text = "\(daysForecast.count) day weather forecast:"
        
        // сохранение в базу Realm
        
        //DataBase.shared.realm.deleteAll()
        //DataBase.shared.realm.beginWrite()
       //DataBase.shared.realm.add(savedObject, update: .all)
        print(DataBase.shared.realm.configuration.fileURL) // подсмотреть путь до базы
       //try! DataBase.shared.realm.commitWrite()
        
        forecastTableView.reloadData()
    }
    
    private func updateCurrentWeather(from result: CurrentWeather){
        currentWeather = result
        weatherInCityLabel.isHidden = false
        weatherIconImageView.isHidden = false
        weatherInCityLabel.text = "Weather in \(currentWeather.name!):"
        
        //FIXME: сделать метод по получению картинки, рассинхозировать загрузку картинки, сохранить ярлык в кеш
        if let iconShortCut = currentWeather.weather.first?.icon {
            let photoUrl = URL(string: "https://openweathermap.org/img/wn/\(iconShortCut)@2x.png")
            print("https://openweathermap.org/img/wn/\(iconShortCut)@2x.png")
            if let data = try? Data(contentsOf: photoUrl!), let image = UIImage(data: data) {
               self.weatherIconImageView.image = image
            }
        }
        
        currentTemperatureLabel.isHidden = false
        currentTemperatureLabel.text = "\(convertKelvToCelsius(currentWeather.main?.temp)!)°C"
        
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
