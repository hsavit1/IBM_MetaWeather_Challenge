//
//  ForecastViewController.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import UIKit
import ReSwift

class ForecastViewController: UIViewController {

    var city: City? = nil
    
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = ""
        
        // NOTE
        //
        // This is hacky! I grab the last view controller that I pushed from
        // If it was the history controller, I need to perform another API request to get the 5 day forecast.
        for viewController in (self.navigationController?.viewControllers)!.reversed() {
            if viewController is MainViewController {
                self.city = mainStore.state.currentCity
                self.title = self.city?.title
                self.activityIndicator.isHidden = true
                self.tableView.reloadData()
            }
            else if viewController is HistoryViewController {
                self.city = mainStore.state.currentHistoryDetailCity
                self.title = self.city?.title
                
                self.tableView.isHidden = true
                
                self.view.bringSubview(toFront: self.activityIndicator)
                self.activityIndicator.isHidden = false
                self.activityIndicator.startAnimating()
                
                self._fetchForecastForCityFromHistory(self.city!.woeid) { [] (error) in
                    if let error = error {
                        print(error)
                    }
                    self.tableView.isHidden = false
                    self.activityIndicator.isHidden = true
                    self.activityIndicator.stopAnimating()
                    self.tableView.reloadData()
                }
            }
            continue
        }
        
        self.navigationItem.hidesBackButton = true
        let newBackButton = UIBarButtonItem(title: "Back", style: UIBarButtonItemStyle.plain, target: self, action: #selector(ForecastViewController.back(sender:)))
        self.navigationItem.leftBarButtonItem = newBackButton
    }
    
    
    func _fetchForecastForCityFromHistory(_ woeid: Int, completion: ((Error?) -> Void)?) {
        let API = "https://www.metaweather.com/api"
        let searchAPI = "/location/search"

        if let url = URL(string: "\(API)\(searchAPI)/location/\(woeid)") {
            let req = NSMutableURLRequest(url: url) as URLRequest
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let data = data {
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        let city = try decoder.decode(City.self, from: data)
                        self.city = city
                        completion?(nil)
                    } catch {
                        completion?(error)
                    }
                }
            })
            task.resume()
        }
    }

    
    @objc func back(sender: UIBarButtonItem) {
        
        for viewController in (self.navigationController?.viewControllers)!.reversed() {
            if viewController is MainViewController {
                (viewController as! MainViewController).justPoppedFromCityDetail = (self.city?.title)!
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
}

extension ForecastViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 7
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let ip = indexPath.item
        
        if ip == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "jumboCell", for: indexPath) as! JumboWeatherTableViewCell
            
            if let todaysForecast: Forecast = self.city?.consolidated_weather?[0] {
                cell.bigTemperature.text = "\(celciusToFahrenheit(todaysForecast.the_temp))°"
                cell.highTempLabel.text = "\(celciusToFahrenheit(todaysForecast.max_temp))°"
                cell.lowTempLabel.text = "\(celciusToFahrenheit(todaysForecast.min_temp))°"
                cell.weatherDescLabel.text = "\(todaysForecast.weather_state_name)"
                cell.weatherAbreviation = todaysForecast.weather_state_abbr
            }
            return cell
        }
        else if ip == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "forecastCell", for: indexPath)
            return cell
        }
        else if ip >= 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "fiveDayCell", for: indexPath) as! WeatherCell
            
            if let todaysForecast: Forecast = self.city?.consolidated_weather?[indexPath.item-1] {
                
                cell.lowTempLabel.text = "\(celciusToFahrenheit(todaysForecast.min_temp))°"
                cell.highTempLabel.text = "\(celciusToFahrenheit(todaysForecast.max_temp))°"
                cell.weekdayLabel.text = "\(getDay(todaysForecast.applicable_date) ?? "")"
                cell.weatherAbreviation = todaysForecast.weather_state_abbr
            }
            
            return cell
        }
        
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let ip = indexPath.item
        
        if ip == 0 { return self.view.frame.size.height * 0.75 }
        else if ip == 1 { return 60 }
        else if ip >= 2 { return 60 }
        
        return 0
    }
    
}

extension ForecastViewController: UITableViewDelegate {
    
}
