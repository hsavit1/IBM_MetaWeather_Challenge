//
//  Search.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/4/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation

struct CityObj {
    
    var objectID: String?
    var keyword: String
    var date: NSDate
    
    init(keyword: String, date: NSDate) {
        self.init(objectID: nil, keyword: keyword, date: date)
    }
    
    init(objectID: String?, keyword: String, date: NSDate) {
        self.objectID = objectID
        self.keyword = keyword
        self.date = date
    }
    
}
