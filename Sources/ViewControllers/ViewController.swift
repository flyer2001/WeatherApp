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

let domain = "https://api.openweathermap.org"
let dataVersionMethod = "/data/2.5"

var params: Parameters = [
    "q": "",
    "mode": "JSON",
    "APPID": "c21154f65ac934ec1c3af7b754337205",
    "units": "metric"
]

enum WeatherMethod: String {
    case current = "weather"
    case forecast = "forecast"
}

class ViewController: UIViewController {

    var forecast = Forecast()
    var currentWeather = CurrentWeather()
    var daysForecast = [DayForecast]()
    var selectedCity = ""
    var cityOfSearchArray = [String]()
    var isTableViewUpdateFromCache = true
    let cellIdentifier = "cell"
    var getStatusFlag = false
    let timeOutButtonInterval = 3.0  // интервал заморозки кнопки "Get Forecast"
    
    @IBOutlet weak var getForecastButton: UIButton!
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
        forecastTableView.alwaysBounceVertical = false
        
        weatherInCityLabel.isHidden = true
        currentTemperatureLabel.isHidden = true
        currentWeatherDescLabel.isHidden = true
        forecastTableView.isHidden = true
        forecastNoticeLabel.isHidden = true
        weatherIconImageView.isHidden = true
        
        dropDownMenuOfSavedSearch.text = "Choose"
        dropDownMenuOfSavedSearch.isSearchEnable = true
        dropDownMenuOfSavedSearch.didSelect{(selectedText, index, id) in
            self.selectedCity = selectedText
            self.offlineUpdate()
        }
        offlineUpdate()
    }
    
    private func offlineUpdate() {
        weatherIconImageView.isHidden = true
        forecastNoticeLabel.text = "Press button"
        
        //удалим устаревшие объекты
        let currentTimeStamp = getCurrentTimeStamp()
        let filterForOldForecast = "dt < \(currentTimeStamp)"
        DataBase.shared.delete(DayForecast.self, filter: filterForOldForecast)
        
        //Загружаем список запросов из кеша
        let indexesForecast = DataBase.shared.getDataFromDB(ofType: IndexForecast.self)
        let convertIndexToArray = Array(indexesForecast)
        let dateArray = convertIndexToArray.compactMap{$0.timeStamp.value}
        let lastTimeStamp = dateArray.max()
        cityOfSearchArray = convertIndexToArray.compactMap{$0.cityKey}
        
        //Заполнить выпадающее меню списком запросов
        dropDownMenuOfSavedSearch.optionArray = cityOfSearchArray.reversed()
        
        //Выбор фильтрации: по городу или по последнему файлу
        var predicate = NSPredicate()
        switch selectedCity.count {
        case 0:
            predicate = NSPredicate(format: "timeStamp == \(lastTimeStamp ?? 0)")
        default:
            predicate = NSPredicate(format: "cityKey = '\(selectedCity)'")
        }
        
        //получаем объект из кеша и заполняем лейблы и данные для таблицы
        if let lastCacheObjects = DataBase.shared.getDataFromDB(ofType: IndexForecast.self).filter(predicate).first {
            if let lastForecastFromCache = lastCacheObjects.forecast {
                let convertForecastListArray = Array(lastForecastFromCache.list)
                daysForecast = convertForecastListArray.filter{($0.dt_txt!.contains("12:00:00"))}
                
                forecastNoticeLabel.text = "\(daysForecast.count) day weather forecast:"
                
                let currentTimeForecastFiltered = convertForecastListArray.filter{$0.dt.value ?? 0 > currentTimeStamp}
                if let currentWeatherForecast = currentTimeForecastFiltered.first {
                    if let currentTemp = currentWeatherForecast.main?.temp.value {
                        currentTemperatureLabel.text = "\(Int(currentTemp)) °C"
                    }
                    weatherInCityLabel.isHidden = false
                    currentTemperatureLabel.isHidden = false
                    currentWeatherDescLabel.isHidden = false
                    
                    currentWeatherDescLabel.text = "\(currentWeatherForecast.weather.first?.desc ?? "Error")"
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
        getForecastButton.isEnabled = false
        getForecastButton.backgroundColor = .gray
        getForecastButton.setTitle("Updating...", for: .normal)
        getStatusFlag = false

        Timer.scheduledTimer(timeInterval: timeOutButtonInterval, target: self, selector: #selector(enableButton), userInfo: nil, repeats: false)
    
        //Если поле нажатия кнопки нет Интернета метод предупреждает пользователя об этом
        checkOfflineMode()
        
        if APIService.shared.checkInternetConnection() == false {
            print("NO INTERNET")
        } else {
            if let city = cityTextField.text {
        
                //Запрос прогноза на 5 дней
                let forecastURL = URL(string: domain)?.appendingPathComponent(dataVersionMethod).appendingPathComponent(WeatherMethod.forecast.rawValue)
                params["q"] = city
                APIService.shared.getObject(url: forecastURL, params: params){
                    [weak self] (result: Swift.Result<Forecast, Error>) in
                    do {
                        let result = try result.get()
                        self?.updateForecast(from: result)
                        self?.getStatusFlag = true
                    } catch (let error) {
                        print("\(error)")
                    }
                }
                
                //Запрос прогноза на текущий день
                let currentWeatherURL = URL(string: domain)?.appendingPathComponent(dataVersionMethod).appendingPathComponent(WeatherMethod.current.rawValue)
                APIService.shared.getObject(url: currentWeatherURL, params: params){
                    [weak self](result: Swift.Result<CurrentWeather, Error>) in
                        do {
                            let result = try result.get()
                            self?.updateCurrentWeather(from: result)
                        } catch (let error) {
                            if let customError = error as? CustomError {
                                if let message = customError.message {
                                    self?.getStatusFlag = true
                                    self?.weatherInCityLabel.isHidden = false
                                    self?.weatherInCityLabel.text = message
                                }
                            }
                        }
                }
            }
        }
    }
    
    @objc func enableButton() {
        getForecastButton.setTitle("Get Forecast", for: .normal) 
        getForecastButton.backgroundColor = .blue
        getForecastButton.isEnabled = true
        if getStatusFlag == false {
            weatherInCityLabel.isHidden = false
            weatherInCityLabel.text = "Check your internet connection"
        }
    }
    
    private func checkOfflineMode(){
        if APIService.shared.checkInternetConnection() == false {
            weatherInCityLabel.isHidden = false
            weatherInCityLabel.text = "Check your internet connection"
        }
    }

    private func updateForecast(from result: Forecast){
        forecast = result
        
        //Модель IndexForecast - для хранения запросов и результатов
        var savedObject = IndexForecast()
        var checkToUpdate: Results<Forecast>
        
        if let cityFromJSON = forecast.city?.name {
            //добавляем город в выпадающее меню
            cityOfSearchArray = cityOfSearchArray.filter{$0 != cityFromJSON}
            cityOfSearchArray.insert(cityFromJSON, at: 0)
            dropDownMenuOfSavedSearch.optionArray = cityOfSearchArray
            
            savedObject = IndexForecast(cityKey: cityFromJSON, forecast: forecast, timeStamp: RealmOptional(getCurrentTimeStamp()))
            savedObject.forecast?.cityKey = cityFromJSON
            checkToUpdate = DataBase.shared.getDataFromDB(ofType:Forecast.self).filter("cityKey CONTAINS[c] '\(cityFromJSON)'")
            
            if checkToUpdate.count == 0 {
                if let dayForecastUpdate = savedObject.forecast?.list {
                    for dayForecast in dayForecastUpdate {
                        dayForecast.id = UUID().uuidString
                        dayForecast.main?.id = UUID().uuidString
                    }
                }
                DataBase.shared.update(savedObject)
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
        currentTemperatureLabel.isHidden = false
        
        weatherInCityLabel.text = "Weather in \(currentWeather.name ?? "Error"):"
        
        if let iconShortCut = currentWeather.weather.first?.icon {
            self.weatherIconImageView.loadWeatherIcon(from: iconShortCut)
        }
        
        if let currentTemperature = currentWeather.main?.temp.value {
            currentTemperatureLabel.text = "\(Int(currentTemperature)) °C"
        }
    }
    
}

//MARK: -UITableViewDataSource

extension ViewController: UITableViewDataSource {
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return daysForecast.count
    }
   
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier) as! ForecastTableViewCell
        if let currentTemperature = daysForecast[indexPath.row].main?.temp.value {
            cell.cellLabel.text = "\(Int(currentTemperature)) °C"
        }
        cell.setDateLabel(daysForecast[indexPath.row].dt_txt)
        
        //Какие данные подгружать в таблицу в зависимости от того из кеша загружается или с Инета
        if isTableViewUpdateFromCache == false {
            
            cell.textWeatherDescLabel.isHidden = true
            cell.forecastIconImageView.isHidden = false
            cell.setImage(daysForecast[indexPath.row].weather.first?.icon)
            
        } else {
            cell.textWeatherDescLabel.isHidden = false
            cell.forecastIconImageView.isHidden = true
            cell.textWeatherDescLabel.text = daysForecast[indexPath.row].weather.first?.desc
        }
        return cell
    }
}

//MARK: -UIIMageView

extension UIImageView {
    func loadWeatherIcon(from shortcut: String) {
        let photoUrl = URL(string: "https://openweathermap.org/img/wn/\(shortcut)@2x.png")
        let queue = DispatchQueue.global(qos: .utility)
        queue.async{
            DispatchQueue.main.async {
                if let data = try? Data(contentsOf: photoUrl!), let image = UIImage(data: data) {
                    self.image = image
                }
            }
        }
    }
}


