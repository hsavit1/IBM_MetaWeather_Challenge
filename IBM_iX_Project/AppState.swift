//
//  AppState.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import ReSwift
import CoreLocation

// Send a ReSwift action to the reducer to update the state!
// In a bigger app with many actions, break this up and combine with combineActionCreators
enum AppStateAction: Action {
    
    // Core Data Actions
    case fetchHistory([City])
    case saveCity(City)
    
    // API Actions
    case changeCurrentCityForecast(City)
    case addCities([City])
    
    // Hacky to get around History -> Detail Forecast
    case changeCurrentCityForecastFromHistory(City)
    case addHistoryDetailCities([City])
    
    // Async Actions
    case readySearch
    case search(String)
    case cancelSearch
}




enum SearchState {
    case canceled
    case ready
    case searching(String)
}

// NOTES
//
// Right now, I am only modelling a few things in my app state. The fetched cities, the coredata cities, etc.
//
// If I had time, I would have added more information, such as coreLocation stuff, into the app state
// The more logic you can into the state, the more you can declaratively control the flow of the application
// The UI should *ideally* be as pure a function of the state as possible

struct AppState: StateType {
    var currentCity: City?
    var currentForecast: Forecast?
    
    var currentHistoryDetailCity: City?
    var currentHistoryDetailForecast: City?
    
    var cities: [City] = []
    
    var savedCities: [City] = []
    
    var search: SearchState = .ready
    
}

// NOTES
//
// Normally, in a redux flavored application, the meat and potatoes is in your reducer function
// The reducer should be a pure function that takes an action, and then decalares how your state is going to evolve accordingly
//
// Additionally, in redux, you always want to have it explicitly documented for what part of the search state you are in
// This app could use more integration with the state of the fetch. This would make more sense especially if using middlewares!

func appReducer(action: Action, state: AppState?) -> AppState {
    
    let initState = AppState(currentCity: nil,
                             currentForecast: nil,
                             currentHistoryDetailCity: nil,
                             currentHistoryDetailForecast: nil,
                             cities: [],
                             savedCities: [],
                             search: .ready
                            )
    
    var state = state ?? initState
    
    guard let action = action as? AppStateAction else {
        return state
    }

    switch action {
    case .cancelSearch:
        state.search = .canceled
    case .readySearch:
        state.search = .ready
    case .search(let query):
        state.search = .searching(query)

        
    case .changeCurrentCityForecast(let city):
        state.currentCity = city
    case .addCities(let cities):
        state.cities = cities
        
        
    case .fetchHistory(let cities):
        state.cities = cities
    case .saveCity(let city):
        state.savedCities.append(city)
    
        
    case .addHistoryDetailCities(let cities):
        state.currentHistoryDetailCity = cities.first!
    case .changeCurrentCityForecastFromHistory(let city):
        state.currentHistoryDetailForecast = city

        
    }
    
    return state
}






// NOTES
//
// If I had a little bit more time, it would have been great to have a few middlewares
// middleware could have been made for fetching the CoreLocation and thunk middleware could have been used for API requests
// an additional middleware could have been used for routing
// this would have made this app incredibly easy to test as it would have separated concerns quite well
// There is an offical ReSwift project for time travel debugging that also would have been nice to throw in

let mainStore = Store(
    reducer: appReducer,
    state:  AppState(),
    middleware: []
)
