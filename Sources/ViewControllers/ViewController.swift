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
    
    var forecast = Forecast()
    var currentWeather = CurrentWeather()
    var daysForecast = [DayForecast]()
    var selectedCity = ""
    var predicate = NSPredicate()
    var isTableViewUpdateFromCache = true
    var networkReachabilityManager = Alamofire.NetworkReachabilityManager()
    let REUSE_ID = "cell"
    
    @IBOutlet weak var cityTextField: UITextField!
    @IBOutlet weak var weatherInCityLabel: UILabel!
    @IBOutlet weak var currentTemperatureLabel: UILabel!
    @IBOutlet weak var currentWeatherDescLabel: UILabel!
    @IBOutlet weak var forecastNoticeLabel: UILabel!
    @IBOutlet weak var forecastTableView: UITableView!
    @IBOutlet weak var weatherIconImageView: UIImageView!
    
    @IBOutlet weak var dropDownMenuOfSavedSearch: DropDown!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        currentWeatherDescLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        dropDownMenuOfSavedSearch.text = "Choose"
        dropDownMenuOfSavedSearch.isSearchEnable = false
        dropDownMenuOfSavedSearch.didSelect{(selectedText, index, id) in
            self.selectedCity = selectedText
            self.offlineUpdate()
        }
        
        offlineUpdate()
        //forecastTableView.reloadData()
    }
    
    private func offlineUpdate() {
        weatherIconImageView.isHidden = true
        forecastNoticeLabel.text = "Press button"
        
        //удалим устаревшие объекты
        let currentTimeStamp = getCurrentTimeStamp()
        let dayForecastToDelete = DataBase.shared.realm.objects(DayForecast.self).filter("dt < \(currentTimeStamp)")
        DataBase.shared.realm.beginWrite()
        DataBase.shared.realm.delete(dayForecastToDelete)
        try! DataBase.shared.realm.commitWrite()
        
        //Загружаем список запросов из кеша
        let indexesForecast = DataBase.shared.realm.objects(IndexForecast.self)
        let convertIndexToArray = Array(indexesForecast)
        let dateArray = convertIndexToArray.compactMap{$0.timeStamp.value}
        let lastTimeStamp = dateArray.max()
        let cityOfSearchArray = convertIndexToArray.compactMap{$0.cityKey}
        
        //Заполнить выпадающее меню списком запросов
        dropDownMenuOfSavedSearch.optionArray = cityOfSearchArray
        
        //Выбор фильтрации: по городу или по последнему файлу
        switch selectedCity.count {
        case 0:
            predicate = NSPredicate(format: "timeStamp == \(lastTimeStamp ?? 0)")
        default:
            predicate = NSPredicate(format: "cityKey = '\(selectedCity)'")
        }
        
        //получаем объект из кеша и заполняем лейблы и данные для таблицы
        if let lastCacheObjects = DataBase.shared.realm.objects(IndexForecast.self).filter(predicate).first {
            if let lastForecastFromCache = lastCacheObjects.forecast {
                let convertForecastListArray = Array(lastForecastFromCache.list)
                daysForecast = convertForecastListArray.filter{($0.dt_txt!.contains("12:00:00"))}
                
                forecastNoticeLabel.text = "\(daysForecast.count) day weather forecast:"
                
                let currentTimeForecastFiltered = convertForecastListArray.filter{$0.dt.value ?? 0 > currentTimeStamp}
                if let currentWeatherForecast = currentTimeForecastFiltered.first {
                    let currentTemp = currentWeatherForecast.main?.temp
                    
                    weatherInCityLabel.isHidden = false
                    currentTemperatureLabel.isHidden = false
                    currentWeatherDescLabel.isHidden = false
                    
                    currentWeatherDescLabel.text = "\(currentWeatherForecast.weather.first?.desc ?? "Error")"
                    currentTemperatureLabel.text = "\(convertKelvToCelsius(currentTemp?.value))°C"
                    weatherInCityLabel.text = "Weather in \(lastForecastFromCache.cityKey ?? "Error"):"
                }
            }
        forecastTableView.isHidden = false
        isTableViewUpdateFromCache = true
        forecastTableView.reloadData()
        }
        
        forecastNoticeLabel.isHidden = false
    }
    
    private func getCurrentTimeStamp() -> Int {
        let timeShiftForCurrentLocal: Int = TimeZone.current.secondsFromGMT()
        let currentDate = Date()
        let since1970 = currentDate.timeIntervalSince1970
        let timeStampUTC = Int(since1970) - timeShiftForCurrentLocal
        return timeStampUTC
    }

    
    @IBAction func getForecastButton(_ sender: Any) {
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        currentWeatherDescLabel.isHidden = true
        
        //Если поле нажатия кнопки нет Интернета метод предупреждает пользователя об этом
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
                            print("\(error)")
                            
                            //повторный запрос к серверу, чтобы получить нормальный код ошибки
                            APIServices.shared.getObject(cityName: city, domain: .domainCurrentWeather){
                                [weak self](result: CurrentWeatherError?, error: Error?) in
                                    if let error = error {
                                        print("\(error)")
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
    }
    
    private func checkOfflineMode(){
        if APIServices.shared.checkInternetConnection() == false {
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
        
        //Модель IndexForecast - для хранения запросов и результатов
        var savedObject = IndexForecast()
        var checkToUpdate: Results<Forecast>
        
        if let cityFromJSON = forecast.city?.name {
            savedObject = IndexForecast(cityKey: cityFromJSON, forecast: forecast, timeStamp: RealmOptional(getCurrentTimeStamp()))
            savedObject.forecast?.cityKey = cityFromJSON
            checkToUpdate = DataBase.shared.realm.objects(Forecast.self).filter("cityKey CONTAINS[c] '\(cityFromJSON)'")
            
            //выходим за пределы инкапсуляции и присваеваем primary key id
            if checkToUpdate.count == 0 {
                if let dayForecastUpdate = savedObject.forecast?.list {
                    for dayForecast in dayForecastUpdate {
                        dayForecast.id = UUID().uuidString
                        dayForecast.main?.id = UUID().uuidString
                    }
                }
                DataBase.shared.realm.beginWrite()
                DataBase.shared.realm.add(savedObject, update: .all)
                try! DataBase.shared.realm.commitWrite()
                }
            }
        let convertForecastListArray = Array(forecast.list)
        daysForecast = convertForecastListArray.filter{$0.dt_txt!.contains("12:00:00")}
        
        forecastTableView.isHidden = false
        forecastNoticeLabel.isHidden = false
        isTableViewUpdateFromCache = false
        currentWeatherDescLabel.isHidden = true
        forecastNoticeLabel.text = "\(daysForecast.count) day weather forecast:"
        
        forecastTableView.reloadData()
    }
    
    private func updateCurrentWeather(from result: CurrentWeather){
        currentWeather = result
        weatherInCityLabel.isHidden = false
        weatherIconImageView.isHidden = false
        weatherInCityLabel.text = "Weather in \(currentWeather.name ?? "Error"):"
    
        if let iconShortCut = currentWeather.weather.first?.icon {
            let photoUrl = URL(string: "https://openweathermap.org/img/wn/\(iconShortCut)@2x.png")
            if let data = try? Data(contentsOf: photoUrl!), let image = UIImage(data: data) {
               self.weatherIconImageView.image = image
            }
        }
        
        currentTemperatureLabel.isHidden = false
        currentTemperatureLabel.text = "\(convertKelvToCelsius(currentWeather.main?.temp.value))°C"
        
    }
    
    private func convertKelvToCelsius (_ temp: Double?) -> Int {
        guard let tempValue = temp else {return 999}
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
        let currentTemperature = convertKelvToCelsius(daysForecast[indexPath.row].main?.temp.value)
        cell.setTemperatureLabel("\(currentTemperature ?? 0)°C")
        cell.setDateLabel(daysForecast[indexPath.row].dt_txt)
        
        //Какие данные подгружать в таблицу в зависимости от того из кеша загружается или с Инета
        if isTableViewUpdateFromCache == false {
            
            cell.isHiddenWeatherDescCell(true)
            cell.isHiddenForecastImageView(false)
            cell.setImage(daysForecast[indexPath.row].weather.first?.icon)
            
        } else {
            cell.isHiddenWeatherDescCell(false)
            cell.isHiddenForecastImageView(true)
            cell.setWeatherDescLabel(daysForecast[indexPath.row].weather.first?.desc)
        }
        return cell
    }
}
