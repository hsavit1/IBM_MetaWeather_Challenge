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
    private var flag = false
    
    var justPoppedFromCityDetail = ""
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var historyBarButton: UIBarButtonItem!
    
    // MARK: Lifecycle Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityRepository = appDelegate.cityLocalRepository
        
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if self.searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
    
    // MARK: IBActions
    
    @IBAction func historyButtonTapped(_ sender: Any) {
        self.performSegue(withIdentifier: "showHistory", sender: self)
    }
}

// MARK: UITableViewDelegate

extension MainViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let city: City = self.cities[indexPath.item]
        
        // save city to coredata
        self.cityRepository.createCity(city: city, completionHandler: { user, error in
            DispatchQueue.main.async {
                mainStore.dispatch(AppStateAction.saveCity(city))
            }
        })
        
        
        //special case hack for when the user taps on a cell, goes to the detail view, then goes back to the mainview, and taps on the same cell
        if self.justPoppedFromCityDetail != "" && self.justPoppedFromCityDetail == self.currentCity?.title && city.title == self.justPoppedFromCityDetail {
            self.performSegue(withIdentifier: "showForecast", sender: self)
        }
        else {
            // perform fetch for 5 day forecast
            API_Manager.sharedManager.getForecastFor(city)
        }
        
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: UITableViewDataSource

extension MainViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityCell
        let city = self.cities[indexPath.item]
        cell.cityNameLabel.text = city.title
        cell.locationIDLabel.text = "ID: \(city.woeid)"
        cell.locationTypeLabel.text = "Type: \(city.location_type)"
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 84
    }
}

// MARK: UISearchBarDelegate

extension MainViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text else { return }
        
        let removeSpaces = text.replacingOccurrences(of: " ", with: "+")
        API_Manager.sharedManager.fetchCity(removeSpaces)
    }
}

// MARK: StoreSubscriberDelegate

extension MainViewController: StoreSubscriber {

    // NOTES
    //
    // This is your controller listening to changes to your AppState
    //
    // newState is called upon subscribing as well
    func newState(state: AppState) {
        
        // Reload with cities data after fetch
        if self.cities != state.cities {
            self.cities = state.cities
            self.tableView.reloadData()
        }
        
        else if self.currentCity?.title != state.currentCity?.title {
            self.currentCity = state.currentCity
            self.performSegue(withIdentifier: "showForecast", sender: self)
        }
        
        if self.searchBar.isFirstResponder {
            searchBar.resignFirstResponder()
        }
    }
}


// MARK: CLLocationManagerDelegate

// NOTES
//
// If I had more time, I would have created a CLLocation middleware and ReSwift-ified this logic a bit
// An example of that is here: https://medium.com/intive-developers/reswift-in-practice-1512e0f59eb5
extension MainViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.startUpdatingLocation()
        case .authorizedAlways:
            manager.startUpdatingLocation()
        case .restricted, .denied:
            let alert = UIAlertController(title: "Location Services Disabled",
                                          message: "Please enable Location Services in Settings",
                                          preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
            alert.addAction(okAction)
            
            present(alert, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Error \(error)")
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard !self.flag, let currentLocation = locations.last else {
            return
        }
        
        self.flag = true
        API_Manager.sharedManager.fetchCityFromCoordinates(lat: "\(currentLocation.coordinate.latitude)", long: "\(currentLocation.coordinate.longitude)")
    }
}

