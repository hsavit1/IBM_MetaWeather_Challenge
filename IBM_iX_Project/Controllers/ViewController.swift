//
//  ViewController.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/4/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import UIKit
import ReSwift
import CoreLocation

class MainViewController: UIViewController {

    var cities: [City] = []
    var currentCity: City? = nil

    var cityRepository: CityLocalRepository!

    private let locationManager = CLLocationManager()
    private var locationOnce = false
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyBarButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityRepository = appDelegate.cityLocalRepository

        
        locationManager.delegate = self
//        locationManager.startUpdatingLocation()
        locationManager.requestWhenInUseAuthorization()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        appStore.subscribe(self)
        
        if(CLLocationManager.authorizationStatus() == .authorizedWhenInUse) {
            if let currentLocation = self.locationManager.location {
                self.fetchCityFromCoordinates(lat: "\(currentLocation.coordinate.latitude)", long: "\(currentLocation.coordinate.longitude)")
            }
        }
        else {
//            mainStore.dispatch(FetchCities)
//            mainStore.dispatch()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        appStore.unsubscribe(self)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    
    
    func getCityFromCoordinates() {
        
    }
    
    
    
    func getWeather(_ city: City) {
        
        let woeid = city.woeid
        
        API_Manager.sharedManager().getWeatherFromCity(woeid, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    appStore.dispatch(
                        AppStateAction.changeCurrentCity(API_Manager.sharedManager().location)
                    )
                }
            }
        })
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "showHistory") {
            let viewController = segue.destination as! HistoryViewController
//            viewController.woeid = self.location.woeid
//            viewController.shouldSaveLocation = true
        }
        else if(segue.identifier == "showForecast") {
//            let viewController = segue.destination as! ForecastViewController
            
        }
        
    }


    @IBAction func historyButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showHistory", sender: self)
    }
    
    func fetchCity(_ name: String) {
        API_Manager.sharedManager().fetchCity(name, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    appStore.dispatch(
                        AppStateAction.addCities(API_Manager.sharedManager().locations)
                    )
                }
            }
        })
    }
    
    func fetchCityFromCoordinates(lat: String, long: String) {
        API_Manager.sharedManager().fetchCityFromCoordinates(lat, long, completion: { [] (error) in
            if let error = error {
                print(error)
            } else {
                DispatchQueue.main.async {
                    appStore.dispatch(
                        AppStateAction.addCities(API_Manager.sharedManager().locations)
                    )
                }
            }
        })
    }
}

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let city: City = self.cities[indexPath.item]
        
        //dispatch action to save city to history
        self.cityRepository.createCity(city: city, completionHandler: { user, error in
            DispatchQueue.main.async {
                appDelegate.mainStore.dispatch(AppStateAction.saveCity(city))
            }
        })
        
        //perform fetch for 5 day forecast
        //        appStore.dispatch(AppStateAction.changeCurrentCity(city)
        
        //once good information comes back, perform segue
        self.performSegue(withIdentifier: "showForecast", sender: self)
    }
}

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityCell
        let city = self.cities[indexPath.item]
        cell.cityNameLabel.text = city.title
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        self.fetchCity(text)
    }
}

extension MainViewController: StoreSubscriber {
    
    func newState(state: AppState) {
        
        if(self.cities != state.cities) {
            self.cities = state.cities
            self.tableView.reloadData()
        }
        else if(self.currentCity != state.currentCity) {
            self.performSegue(withIdentifier: "showForecast", sender: self)
        }
   
        switch (self.searchBar.isFirstResponder) {
        case true: searchBar.resignFirstResponder()
        case false: searchBar.becomeFirstResponder()
        }
    }
}


// MARK: CLLocationManagerDelegate
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !locationOnce else { return }
        guard let currentLocation = locations.last else { return }

        locationOnce = true
        self.fetchCityFromCoordinates(lat: "\(currentLocation.coordinate.latitude)", long: "\(currentLocation.coordinate.longitude)")
    }

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            let alert = UIAlertController(title: "Location Services Disabled", message: "Please enable Location Services in Settings", preferredStyle: .alert)

            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)

            present(alert, animated: true, completion: nil)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
}

