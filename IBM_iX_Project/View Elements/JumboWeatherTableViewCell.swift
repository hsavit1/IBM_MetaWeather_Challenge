//
//  JumboWeatherTableViewCell.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import UIKit

class JumboWeatherTableViewCell: UITableViewCell {

    @IBOutlet weak var bigTemperature: UILabel!
    @IBOutlet weak var highTempLabel: UILabel!
    @IBOutlet weak var lowTempLabel: UILabel!
    
    @IBOutlet weak var weatherDescLabel: UILabel!
    
    @IBOutlet weak var weatherImage: UIImageView!
    
    var weatherAbreviation: String = ""
    var initializedFlag = false
    
    override func layoutSubviews() {
        super.layoutSubviews()

        guard initializedFlag == false else { return }
        initializedFlag = true

        let iconUrl = "https://www.metaweather.com/static/img/weather/png/"
        self.weatherImage.load(url: "\(iconUrl)\(self.weatherAbreviation).png")
    }
}
