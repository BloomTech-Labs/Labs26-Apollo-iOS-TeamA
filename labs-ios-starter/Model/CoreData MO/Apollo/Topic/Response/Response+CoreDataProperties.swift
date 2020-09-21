// Copyright © 2020 Shawn James. All rights reserved.
// Response+CoreDataProperties.swift
//

import CoreData
import Foundation

extension Response {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Response> {
        return NSFetchRequest<Response>(entityName: "Response")
    }

    @NSManaged public var id: UUID
    @NSManaged public var questionId: UUID
    @NSManaged public var response: String
    @NSManaged public var respondedBy: Member
    @NSManaged public var topic: Topic
}
