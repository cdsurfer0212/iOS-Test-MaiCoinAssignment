//
//  FavoriteCoreData.swift
//  MaiCoinAssignment
//
//  Created by Sean Zeng on 2018/6/25.
//  Copyright © 2018 Sean Zeng. All rights reserved.
//

import CoreData
import Foundation

class FavoriteCoreData {
    
    private static let persistentContainer = (UIApplication.shared.delegate as! AppDelegate).persistentContainer
    
    static func delete(cryptocurrencyId: Int) {
        persistentContainer.performBackgroundTask({ (managedObjectContext) in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
            request.predicate = NSPredicate(format: "cryptocurrencyId = %ld", cryptocurrencyId)
            do {
                let results = try managedObjectContext.fetch(request)
                for result in results as! [NSManagedObject] {
                    managedObjectContext.delete(result)
                }
                
                try managedObjectContext.save()
                
                NotificationCenter.default.post(name: Notification.Name("FavoriteSavedNotification"), object: nil)
            } catch {
                // FIXME
                print(error)
            }
        })
    }
    
    static func getAllCryptocurrency() -> [Cryptocurrency]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
        request.propertiesToFetch = ["cryptocurrencyId"]
        //request.returnsDistinctResults = true
        request.returnsObjectsAsFaults = false
        var data: [Cryptocurrency] = [Cryptocurrency]()
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            var set = Set<Int>()
            for result in results as! [NSManagedObject] {
                let id = result.value(forKey: "cryptocurrencyId") as! Int
                if !set.contains(id), let cryptocurrency = CryptocurrencyCoreData.getById(id: id) {
                    data.append(cryptocurrency)
                    set.insert(id)
                }
            }
        } catch {
            // FIXME
            print(error)
        }
        return data
    }
    
    static func getFiatCurrencySymbolsBy(cryptocurrencyId: Int) -> [String]? {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
        request.predicate = NSPredicate(format: "cryptocurrencyId = %ld", cryptocurrencyId)
        request.returnsObjectsAsFaults = false
        var data: [String] = [String]()
        do {
            let results = try persistentContainer.viewContext.fetch(request)
            for result in results as! [NSManagedObject] {
                if let fiatCurrencySymbol = result.value(forKey: "fiatCurrencySymbol") {
                    data.append(fiatCurrencySymbol as! String)
                }
            }
        } catch {
            // FIXME
            print(error)
        }
        return data
    }
    
    static func insert(cryptocurrencyId: Int, fiatCurrencySymbol: String) {
        persistentContainer.performBackgroundTask({ (managedObjectContext) in
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
            request.predicate = NSPredicate(format: "cryptocurrencyId = %ld AND fiatCurrencySymbol = %@", cryptocurrencyId, fiatCurrencySymbol)
            do {
                let managedObject: NSManagedObject
                let results = try managedObjectContext.fetch(request)
                if let existingManagedObject = results.first {
                    managedObject = existingManagedObject as! NSManagedObject
                } else {
                    let entity = NSEntityDescription.entity(forEntityName: "FavoriteEntity", in: managedObjectContext)
                    managedObject = NSManagedObject(entity: entity!, insertInto: managedObjectContext)
                }
                managedObject.setValue(cryptocurrencyId, forKey: "cryptocurrencyId")
                managedObject.setValue(fiatCurrencySymbol, forKey: "fiatCurrencySymbol")
                
                try managedObjectContext.save()
                
                NotificationCenter.default.post(name: Notification.Name("FavoriteSavedNotification"), object: nil)
            } catch {
                // FIXME
                print(error)
            }
        })
    }

    static func isFavorite(cryptocurrencyId: Int) -> Bool {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "FavoriteEntity")
        request.predicate = NSPredicate(format: "cryptocurrencyId = %ld", cryptocurrencyId)
        request.returnsObjectsAsFaults = false
        var results: [Any] = [Any]()
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            // FIXME
            print(error)
        }
        return results.count > 0
    }
    
}
