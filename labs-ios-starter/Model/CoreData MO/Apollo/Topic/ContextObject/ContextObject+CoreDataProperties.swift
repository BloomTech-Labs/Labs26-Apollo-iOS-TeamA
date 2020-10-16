// Copyright © 2020 Shawn James. All rights reserved.
// ContextQuestion+CoreDataProperties.swift
//

import CoreData
import Foundation

extension ContextQuestion {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContextQuestion> {
        return NSFetchRequest<ContextQuestion>(entityName: "ContextQuestion")
    }

    @NSManaged public var id: Int64
    @NSManaged public var title: String
}
