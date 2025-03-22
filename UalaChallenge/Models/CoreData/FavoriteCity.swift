//
//  FavoriteCity.swift
//  UalaChallenge
//
//  Created by Luis Barrios on 20/3/25.
//


import CoreData

@objc(FavoriteCity)
public class FavoriteCity: NSManagedObject {
    @NSManaged public var id: Int64

    convenience init(cityID: Int, context: NSManagedObjectContext) {
        self.init(context: context)
        self.id = Int64(cityID)
    }

    @nonobjc public class func fetchRequest() -> NSFetchRequest<FavoriteCity> {
        return NSFetchRequest<FavoriteCity>(entityName: "FavoriteCity")
    }


}
