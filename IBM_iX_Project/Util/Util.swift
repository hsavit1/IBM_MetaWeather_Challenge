//
//  Util.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import UIKit

public func celciusToFahrenheit(_ c: Double) -> Int {
    let f = c * 9 / 5 + 32
    return Int(f.rounded())
}

public func getDay(_ day: String) -> String? {

    let formatter  = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"

    guard let date = formatter.date(from: day) else { return nil }

    let cal = Calendar(identifier: .gregorian).component(.weekday, from: date)
    switch cal {
    case 1:
        return "Sunday"
    case 2:
        return "Monday"
    case 3:
        return "Tuesday"
    case 4:
        return "Wednesday"
    case 5:
        return "Thursday"
    case 6:
        return "Friday"
    case 7:
        return "Saturday"
    default:
        return ""
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

extension UIImageView {
    func load(url: String) {
        if let url = URL(string: url) {
            DispatchQueue.global().async {
                do {
                    let imageData = try Data(contentsOf: url)
                    DispatchQueue.main.async {
                        self.image = UIImage(data: imageData)
                        UIView.animate(withDuration: 0.5,
                                       delay: 0.1,
                                       usingSpringWithDamping: 1.0,
                                       initialSpringVelocity: 2,
                                       options: [.allowUserInteraction, .allowAnimatedContent],
                                       animations: { () -> Void in
                                        self.alpha = 1
                        }
                        )
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
            self.alpha = 0
        }
    }
}

