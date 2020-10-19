//
//  RequestQuestion+CoreDataProperties.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/19/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData
import Foundation

extension RequestQuestion {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<RequestQuestion> {
        return NSFetchRequest<RequestQuestion>(entityName: "ContextQuestion")
    }

    @NSManaged public var id: Int64
    // var contextId: Int
    @NSManaged public var question: String
    @NSManaged public var ratingStyle: String
    @NSManaged public var reviewType: String
    @NSManaged public var topic: Topic
}
