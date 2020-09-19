// Copyright © 2020 Shawn James. All rights reserved.
// Member+CoreDataProperties.swift

import CoreData
import UIKit

extension Member {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Member> {
        return NSFetchRequest<Member>(entityName: "Member")
    }

    @NSManaged public var oktaID: String?
//    @NSManaged public var id: Int64
    public var id: Int64? {
        get {
            willAccessValue(forKey: "id")
            defer { didAccessValue(forKey: "id") }

            return primitiveValue(forKey: "id") as? Int64
        }
        set {
            willChangeValue(forKey: "id")
            defer { didChangeValue(forKey: "id") }

            guard let value = newValue else {
                setPrimitiveValue(nil, forKey: "id")
                return
            }
            setPrimitiveValue(value, forKey: "id")
        }
    }

    @NSManaged public var email: String?
    @NSManaged public var firstName: String?
    @NSManaged public var lastName: String?
    @NSManaged public var avatarURL: URL?

    // holds image after downloading in UserDetailVC
    @NSManaged public var image: UIImage?

    // MARK: - Inverse relationships

    @NSManaged public var response: Response?
    @NSManaged public var topic: Topic?
}
