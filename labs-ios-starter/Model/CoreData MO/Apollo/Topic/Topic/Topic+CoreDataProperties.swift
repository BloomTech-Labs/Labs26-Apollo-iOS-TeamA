// Copyright © 2020 Shawn James. All rights reserved.
// Topic+CoreDataProperties.swift
//

import CoreData
import Foundation

extension Topic {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Topic> {
        return NSFetchRequest<Topic>(entityName: "Topic")
    }

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

    @NSManaged public var joinCode: String?
    @NSManaged public var leaderId: String
    @NSManaged public var topicName: String?
    //    @NSManaged public var contextId: Int64
    public var contextId: Int64? {
        get {
            willAccessValue(forKey: "contextId")
            defer { didAccessValue(forKey: "contextId") }

            return primitiveValue(forKey: "contextId") as? Int64
        }
        set {
            willChangeValue(forKey: "contextId")
            defer { didChangeValue(forKey: "contextId") }

            guard let value = newValue else {
                setPrimitiveValue(nil, forKey: "contextId")
                return
            }
            setPrimitiveValue(value, forKey: "contextId")
        }
    }

    @NSManaged public var timeStamp: String?

    // MARK: - Relationships

    @NSManaged public var members: NSSet?

    // MARK: - App Use

    @NSManaged public var questionsToSend: Array<Int>? // coding key assigned
    @NSManaged public var responsesToSend: Array<Int>? // coding key assigned

    // relationships (app use)

    @NSManaged public var contextQuestions: NSSet? // doesn't get sent
    @NSManaged public var requestQuestions: NSSet? // doesn't get sent

    // Sections (Used for CollectionView Headers)

    @NSManaged public var section: String?
}

// MARK: Generated accessors for members

extension Topic {
    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: Member)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: Member)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)
}

// MARK: Generated accessors for questions

extension Topic {
    @objc(addContextQuestionsObject:)
    @NSManaged public func addToContextQuestions(_ value: ContextQuestion)

    @objc(removeContextQuestionsObject:)
    @NSManaged public func removeFromContextQuestions(_ value: ContextQuestion)

    @objc(addRequestQuestionsObject:)
    @NSManaged public func addToRequestQuestions(_ value: RequestQuestion)

    @objc(removeRequestQuestionsObject:)
    @NSManaged public func removeFromRequestQuestions(_ value: RequestQuestion)

    @objc(addContextQuestions:)
    @NSManaged public func addToContextQuestions(_ values: NSSet)

    @objc(addRequestQuestions:)
    @NSManaged public func addToRequestQuestions(_ values: NSSet)

    @objc(removeContextQuestions:)
    @NSManaged public func removeFromContextQuestions(_ values: NSSet)

    @objc(removeRequestQuestions:)
    @NSManaged public func removeFromRequestQuestions(_ values: NSSet)
}


