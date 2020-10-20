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
    @NSManaged public var responses: NSSet
}

// MARK: Generated accessors for responses

extension ContextQuestion {
    @objc(addResponsesObject:)
    @NSManaged public func addToResponses(_ value: ContextResponse)

    @objc(removeResponsesObject:)
    @NSManaged public func removeFromResponses(_ value: ContextResponse)

    @objc(addResponses:)
    @NSManaged public func addToResponses(_ values: NSSet)

    @objc(removeResponses:)
    @NSManaged public func removeFromResponses(_ values: NSSet)
}
