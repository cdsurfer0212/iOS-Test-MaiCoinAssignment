//
//  CryptocurrencyCoreData.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/25.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import CoreData
import Foundation

class CryptocurrencyCoreData {
    
    private static let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    static func getAll() -> [Cryptocurrency]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CryptocurrencyEntity")
        request.returnsObjectsAsFaults = false
        var data: [Cryptocurrency] = [Cryptocurrency]()
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            for result in results as! [NSManagedObject] {
                let cryptocurrencyEntity = NSKeyedUnarchiver.unarchiveObject(with: result.value(forKey: "data") as! Data) as! Cryptocurrency
                data.append(cryptocurrencyEntity)
            }
        } catch {
            // FIXME
            print(error)
        }
        return data
    }
    
    static func getById(id: Int) -> Cryptocurrency? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CryptocurrencyEntity")
        request.predicate = NSPredicate(format: "id = %ld", id)
        request.returnsObjectsAsFaults = false
        var data: Cryptocurrency?
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            for result in results as! [NSManagedObject] {
                data = NSKeyedUnarchiver.unarchiveObject(with: result.value(forKey: "data") as! Data) as? Cryptocurrency
            }
        } catch {
            // FIXME
            print(error)
        }
        return data
    }
    
    static func insert(cryptocurrencys: [Cryptocurrency]) {
        persistentContainer.performBackgroundTask({ (managedObjectContext) in
            cryptocurrencys.forEach({ (cryptocurrency) in
                let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CryptocurrencyEntity")
                request.predicate = NSPredicate(format: "id = %ld", cryptocurrency.id!)
                do {
                    let managedObject: NSManagedObject
                    let results = try managedObjectContext.fetch(request)
                    if let existingManagedObject = results.first {
                        managedObject = existingManagedObject as! NSManagedObject
                    } else {
                        let entity = NSEntityDescription.entity(forEntityName: "CryptocurrencyEntity", in: managedObjectContext)
                        managedObject = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                    }
                    managedObject.setValue(cryptocurrency.id, forKey: "id")
                    managedObject.setValue(NSKeyedArchiver.archivedData(withRootObject: cryptocurrency), forKey: "data")
                } catch {
                    // FIXME
                    print(error)
                }
            })
            
            do {
                try managedObjectContext.save()
            } catch {
                // FIXME
                print(error)
            }
        })
    }
    
}
