// Copyright © 2020 Shawn James. All rights reserved.
// ContextObject+CoreDataProperties.swift
//

import CoreData
import Foundation

extension ContextObject {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContextObject> {
        return NSFetchRequest<ContextObject>(entityName: "ContextObject")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String
}
