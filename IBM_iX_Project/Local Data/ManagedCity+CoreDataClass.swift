//
//  ManagedCity+CoreDataClass.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//
//

import Foundation
import CoreData

@objc(ManagedCity)
public class ManagedCity: NSManagedObject {
    func toCityObj() -> CityObj {
        return CityObj(objectID: self.objectID.uriRepresentation().absoluteString,
                       keyword: self.keyword ?? "",
                       date: self.timeStamp ?? NSDate()
        )
    }
}
