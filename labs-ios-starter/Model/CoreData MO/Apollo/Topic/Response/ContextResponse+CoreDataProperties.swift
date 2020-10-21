// Copyright © 2020 Shawn James. All rights reserved.
// Response+CoreDataProperties.swift
//

import CoreData
import Foundation

extension ContextResponse {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContextResponse> {
        return NSFetchRequest<ContextResponse>(entityName: "ContextResponse")
    }

    @NSManaged public var id: Int64
    @NSManaged public var questionId: Int64
    @NSManaged public var response: String
    @NSManaged public var respondedBy: Member
    @NSManaged public var contextQuestion: ContextQuestion
    @NSManaged public var threads: NSSet
}

// MARK: Generated accessors for Threads

extension ContextResponse {
    @objc(addThreadsObject:)
    @NSManaged public func addToThreads(_ value: Thread)

    @objc(removeThreadsObject:)
    @NSManaged public func removeFromThreads(_ value: Thread)

    @objc(addThreads:)
    @NSManaged public func addToThreads(_ values: NSSet)

    @objc(removeThreads:)
    @NSManaged public func removeFromThreads(_ values: NSSet)
}
