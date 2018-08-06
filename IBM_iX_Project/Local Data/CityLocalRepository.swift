//
//  CityLocalRepository.swift
//  IBM_iX_Project
//
//  Created by Henry Savit on 8/5/18.
//  Copyright © 2018 HenrySavit. All rights reserved.
//

import Foundation
import CoreData

enum RepositoryError {
    case fail
}

typealias FetchCitiesCompletionHandler = (_ cities: [CityObj]?, _ error: RepositoryError?) -> Void
typealias FetchCityCompletionHandler = (_ city: CityObj?, _ error: RepositoryError?) -> Void
typealias CreateCityCompletionHandler = (_ city: CityObj?, _ error: RepositoryError?) -> Void
typealias DeleteCityCompletionHandler = (_ error: RepositoryError?) -> Void

// Explicitly replace core data object each time you save
// This pattern is common in Redux flavored applications and is also seen in immutable.js
struct CityLocalRepository {
    
    private let context: NSManagedObjectContext
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    func fetchCities(completionHandler: FetchCitiesCompletionHandler?) {
        
        context.perform {
            do {
                let request: NSFetchRequest<ManagedCity> = ManagedCity.fetchRequest()
                let managedCities = try self.context.fetch(request)
                
                completionHandler?(managedCities.map { $0.toCityObj() }, nil)
                
            } catch {
                completionHandler?(nil, RepositoryError.fail)
            }
        }
    }
    
    func fetchCity(objectID: String, completionHandler: FetchCityCompletionHandler?) {
        
        context.perform {
            do {
                
                guard let managedObjectId = self.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: objectID)!)
                    else {
                        completionHandler?(nil, RepositoryError.fail)
                        return
                    }
                
                guard let managedCity = try self.context.existingObject(with: managedObjectId) as? ManagedCity
                    else {
                        completionHandler?(nil, RepositoryError.fail)
                        return
                    }
                
                let city: CityObj = managedCity.toCityObj()
                completionHandler?(city, nil)
                
            } catch {
                completionHandler?(nil, RepositoryError.fail)
            }
        }
    }
    
    func createCity(city: City, completionHandler: CreateCityCompletionHandler?) {
        
        context.perform {
            do {
                let managedCity = ManagedCity(context: self.context)
                managedCity.keyword = city.title
                managedCity.timeStamp = NSDate()
                
                try self.context.save()
                completionHandler?(managedCity.toCityObj() ,nil)
                
            } catch {
                completionHandler?(nil, RepositoryError.fail)
            }
        }
    }
    
    func deleteCity(objectID: String, completionHandler: DeleteCityCompletionHandler?) {
        context.perform {
            do {
                guard let managedObjectId = self.context.persistentStoreCoordinator?.managedObjectID(forURIRepresentation: URL(string: objectID)!) else {

                    completionHandler?(RepositoryError.fail)
                    return
                }

                guard let managedCity = try self.context.existingObject(with: managedObjectId) as? ManagedCity else {
                    completionHandler?(RepositoryError.fail)
                    return
                }

                self.context.delete(managedCity)
                try self.context.save()

            } catch {
                completionHandler?(RepositoryError.fail)
            }
        }

    }
    
    
}
