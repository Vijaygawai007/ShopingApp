//
//  Cart_Handler+CoreDataProperties.swift
//  
//
//  Created by Vijay on 16/09/26.
//
//

public import Foundation
public import CoreData


public typealias Cart_HandlerCoreDataPropertiesSet = NSSet

extension Cart_Handler {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Cart_Handler> {
        return NSFetchRequest<Cart_Handler>(entityName: "Cart_Handler")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String?
    @NSManaged public var price: Double
    @NSManaged public var quantity: Int64
    @NSManaged public var total: Double
    @NSManaged public var discountPercentage: Double
    @NSManaged public var discountedTotal: Double
    @NSManaged public var thumbnail: String?

}
