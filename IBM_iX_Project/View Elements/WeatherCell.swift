//
//  WeatherCell.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import UIKit

class WeatherCell : UITableViewCell {
    
    @IBOutlet weak var weatherImageView: UIImageView!
    
    @IBOutlet weak var lowTempLabel: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var weekdayLabel: UILabel!
    
    var weatherAbreviation: String = ""
    var initilizedFlag = false
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard self.initilizedFlag == false else { return }
        
        self.initilizedFlag = true

        let iconUrl = "https://www.metaweather.com/static/img/weather/png/"
        self.weatherImageView.load(url: "\(iconUrl)\(weatherAbreviation).png")
    }
}
