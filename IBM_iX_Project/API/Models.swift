//
//  City.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation

// City data model to resolve JSON into. From MetaWeather API
struct City: Codable, Equatable {
    static func == (lhs: City, rhs: City) -> Bool {
        if( (lhs.title == rhs.title) &&
            (lhs.location_type == rhs.location_type) &&
            (lhs.woeid == rhs.woeid) &&
            (lhs.latt_long == rhs.latt_long)
        ) {
            return true
        }
        return false
    }
    
    let title: String
    let location_type: String
    let woeid: Int
    let latt_long: String
    let consolidated_weather: [Forecast]?
}

struct Forecast: Codable, Equatable {
    static func == (lhs: Forecast, rhs: Forecast) -> Bool {
        if( (lhs.weather_state_name == rhs.weather_state_name) &&
            (lhs.weather_state_abbr == rhs.weather_state_abbr) &&
            (lhs.applicable_date == rhs.applicable_date) &&
            (lhs.min_temp == rhs.min_temp) &&
            (lhs.max_temp == rhs.max_temp) &&
            (lhs.the_temp == rhs.the_temp) &&
            (lhs.humidity == rhs.humidity)
        ) {
            return true
        }
        return false
    }

    let weather_state_name: String
    let weather_state_abbr: String
    let applicable_date: String
    let min_temp: Double
    let max_temp: Double
    let the_temp: Double
    let humidity: Int
}
