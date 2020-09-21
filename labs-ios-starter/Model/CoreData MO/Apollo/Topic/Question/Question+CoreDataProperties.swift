// Copyright © 2020 Shawn James. All rights reserved.
// Question+CoreDataProperties.swift
//

import CoreData
import Foundation

extension Question {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var id: Int64
    // var contextId: Int
    @NSManaged public var question: String
    @NSManaged public var ratingStyle: String
    @NSManaged public var reviewType: String
    @NSManaged public var topic: Topic
}
