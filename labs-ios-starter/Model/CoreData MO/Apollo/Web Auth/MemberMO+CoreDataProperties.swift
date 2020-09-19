// Copyright © 2020 Shawn James. All rights reserved.
// Member+CoreDataProperties.swift
//

import UIKit
import CoreData


extension Member {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Member> {
        return NSFetchRequest<Member>(entityName: "Member")
    }

    @NSManaged public var id: String?
    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var avatarURL: URL?
    @NSManaged public var image: UIImage?
    @NSManaged public var topic: Topic?
    @NSManaged public var response: Response?

}
