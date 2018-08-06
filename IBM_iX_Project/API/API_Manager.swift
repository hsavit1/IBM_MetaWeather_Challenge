//
//  Manager.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import MapKit
import ReSwift


// NOTE
//
// This is quite hacky. I shouldn't need a shared manager. Singletons are bad!
// All of the fetch methods really should be in their own async action creators, managed by thunk middleware
// I didn't have time to set up a ReSwift thunk middleware, so alas, these async actions are being managed by a shared manager
//
// Also, these fetch requests could have looked a lot better with some generic typing
//
// The duplicate functions (the function names ending with ..."FromHistory") are hacky and could be cleaned up significantly
class API_Manager: NSObject {

    static let sharedManager = API_Manager()

    let API = "https://www.metaweather.com/api"
    let searchAPI = "/location/search"
    
    var cities: [City] = []
    var cityForecast: City? = nil
    
    var historyDetailCity: [City] = []
    
    func getForecastFor(_ city: City) {
        self._fetchForecastForCity(city.woeid, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                if let forecast = self.cityForecast {
                    DispatchQueue.main.async {
                        mainStore.dispatch(AppStateAction.changeCurrentCityForecast(forecast) )
                    }
                }
                else {
                    print("Location can't be nil")
                }
            }
        })
    }
    
    func fetchCity(_ name: String) {
        self._fetchCity(name, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    mainStore.dispatch( AppStateAction.addCities(self.cities) )
                }
            }
        })
    }
    func fetchCityFromHistory(_ name: String) {
        self._fetchCityFromHistory(name, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {

                DispatchQueue.main.async {
                    mainStore.dispatch( AppStateAction.addHistoryDetailCities(self.historyDetailCity) )
                }
            }
        })
    }

    
    func fetchCityFromCoordinates(lat: String, long: String) {
        self._fetchCityFromCoordinates(lat, long, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    mainStore.dispatch(
                        AppStateAction.addCities(self.cities)
                    )
                }
            }
        })
    }
    
    
    func _fetchCity(_ query: String, completion: ( (Error?) -> Void)? ) {
        if let url = URL(string: "\(API)\(searchAPI)/?query=\(query)") {
            let req = NSMutableURLRequest(url: url) as URLRequest
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let data = data {
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        self.cities = try decoder.decode([City].self, from: data)
                        completion?(nil)
                    } catch {
                        completion?(error)
                    }
                }
            })
            task.resume()
        }
    }
    func _fetchCityFromHistory(_ query: String, completion: ( (Error?) -> Void)? ) {
        if let url = URL(string: "\(API)\(searchAPI)/?query=\(query)") {
            let req = NSMutableURLRequest(url: url) as URLRequest
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let data = data {
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        self.historyDetailCity = try decoder.decode([City].self, from: data)
                        completion?(nil)
                    } catch {
                        completion?(error)
                    }
                }
            })
            task.resume()
        }
    }

    
    func _fetchForecastForCity(_ woeid: Int, completion: ((Error?) -> Void)?) {
        if let url = URL(string: "\(API)\(searchAPI)/location/\(woeid)") {
            let req = NSMutableURLRequest(url: url) as URLRequest
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let data = data {
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        self.cityForecast = try decoder.decode(City.self, from: data)
                        completion?(nil)
                    } catch {
                        completion?(error)
                    }
                }
            })
            task.resume()
        }
    }
    
    func _fetchCityFromCoordinates(_ lat: String, _ long: String, completion: ((Error?) -> Void)?) {
        if let url = URL(string: "\(API)\(searchAPI)/?lattlong=\(lat),\(long)") {
            let req: URLRequest = NSMutableURLRequest(url: url) as URLRequest
            let task = URLSession.shared.dataTask(with: req, completionHandler: { data, response, error in
                if let data = data {
                    let decoder: JSONDecoder = JSONDecoder()
                    do {
                        self.cities = try decoder.decode([City].self, from: data)
                        print(self.cities)
                        completion?(nil)
                    } catch {
                        completion?(error)
                    }
                }
            })
            task.resume()
        }
    }
}
