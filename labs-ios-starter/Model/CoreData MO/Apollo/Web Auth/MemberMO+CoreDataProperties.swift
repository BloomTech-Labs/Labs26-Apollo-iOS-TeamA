// Copyright © 2020 Shawn James. All rights reserved.
// MemberMO+CoreDataProperties.swift
//

import UIKit
import CoreData


extension MemberMO {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemberMO> {
        return NSFetchRequest<MemberMO>(entityName: "MemberMO")
    }

    @NSManaged public var id: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var image: UIImage?
    @NSManaged public var topic: TopicMO?
    @NSManaged public var response: ResponseMO?

}
