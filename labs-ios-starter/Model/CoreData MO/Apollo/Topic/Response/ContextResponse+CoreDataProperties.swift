// Copyright © 2020 Shawn James. All rights reserved.
// Response+CoreDataProperties.swift
//

import CoreData
import Foundation

extension ContextResponse {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<ContextResponse> {
        return NSFetchRequest<ContextResponse>(entityName: "Response")
    }

    @NSManaged public var id: UUID
    @NSManaged public var questionId: UUID
    @NSManaged public var response: String
    @NSManaged public var respondedBy: Member
    @NSManaged public var contextQuestion: ContextQuestion
}
