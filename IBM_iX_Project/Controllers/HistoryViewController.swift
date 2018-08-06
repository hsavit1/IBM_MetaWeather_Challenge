//
//  HistoryViewController.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import UIKit
import ReSwift

class HistoryViewController: UIViewController {
    
    var cityObjects: [CityObj] = []
    var cityRepository: CityLocalRepository!

    var detailCityName = ""
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.cityRepository = appDelegate.cityLocalRepository
        self.fetchCities()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mainStore.subscribe(self)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        mainStore.unsubscribe(self)
    }

    func fetchCities() {
        //fetch cities on the history screen
        self.cityRepository.fetchCities(completionHandler: { cities, error in
            if error == nil {
                if let cityObjs = cities {
                    self.cityObjects = cityObjs.reversed()
                    self.tableView.reloadData()
                }
            }
            else {
//                print(error)
            }
        })
    }
}

extension HistoryViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.cityObjects.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cityCell", for: indexPath) as! CityCell
        let city = self.cityObjects[indexPath.item]
        
        let timeStamp = city.date
        cell.cityNameLabel.text = city.keyword
        cell.dateSavedLabel?.text = DateFormatter.localizedString(from: timeStamp as Date, dateStyle: .short, timeStyle: .short)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }

}

extension HistoryViewController: UITableViewDelegate {
    
    // NOTE
    //
    // This is a feature that I think makes a lot of sense for an app like this.
    // Swipe on the cell to expose a delete button
    // Tap on delete to remove the city from coredata
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action: UITableViewRowAction, indexPath) in
            
            if let objectToDeleteId = self.cityObjects[indexPath.item].objectID {
                self.cityRepository.deleteCity(objectID: objectToDeleteId, completionHandler: { error in
                })
            }
        
            self.fetchCities()
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //showForecastFromHistory
        
        let cityName = cityObjects[indexPath.item].keyword

        //make sure that
        self.detailCityName = cityName

        //get city from saved city name
        API_Manager.sharedManager.fetchCityFromHistory(cityName)
        
        tableView.deselectRow(at: indexPath, animated: true)
    }

}

extension HistoryViewController: StoreSubscriber {
    
    // NOTES
    //
    // This thing really needs a middleware
    //
    // This app becomes quite stateful without an asyncrhronous middleware
    // When I push to the ForecastViewController, I need to hit the API to get the forecast data for the city. I would
    // much rather take care of that here and save that information to my state object, but it is difficult to pull off without a middleware.
    func newState(state: AppState) {
        if state.currentHistoryDetailCity?.title == self.detailCityName {
            self.performSegue(withIdentifier: "showForecastFromHistory", sender: self)
            self.detailCityName = ""
        }
    }
}

