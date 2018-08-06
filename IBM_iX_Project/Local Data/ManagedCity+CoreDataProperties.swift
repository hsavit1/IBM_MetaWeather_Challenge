//
//  ManagedCity+CoreDataProperties.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//
//

import Foundation
import CoreData


extension ManagedCity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ManagedCity> {
        return NSFetchRequest<ManagedCity>(entityName: "ManagedCity")
    }

    @NSManaged public var keyword: String?
    @NSManaged public var timeStamp: NSDate?

}
