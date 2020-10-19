// Copyright © 2020 Shawn James. All rights reserved.
// Question+CoreDataProperties.swift
//

import CoreData
import Foundation

extension ContextQuestion {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContextQuestion> {
        return NSFetchRequest<ContextQuestion>(entityName: "ContextQuestion")
    }

    @NSManaged public var id: Int64
    // var contextId: Int
    @NSManaged public var question: String
    @NSManaged public var ratingStyle: String
    @NSManaged public var reviewType: String
    @NSManaged public var template: Bool
    @NSManaged public var topic: Topic
}
