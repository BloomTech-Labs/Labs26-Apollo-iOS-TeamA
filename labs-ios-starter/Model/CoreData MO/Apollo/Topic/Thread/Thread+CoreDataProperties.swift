//
//  Thread+CoreDataProperties.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/20/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData
import Foundation

extension Thread {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Thread> {
        return NSFetchRequest<Thread>(entityName: "Thread")
    }

    @NSManaged public var id: Int64
    @NSManaged public var questionId: Int64
    @NSManaged public var contextResponse: ContextResponse
    @NSManaged public var responseId: Int64
    @NSManaged public var repliedBy: String?
}
