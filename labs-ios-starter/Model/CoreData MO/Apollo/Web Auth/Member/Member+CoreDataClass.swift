// Copyright © 2020 Shawn James. All rights reserved.
// Member+CoreDataClass.swift

import CoreData
import UIKit

/// Standard user, leader if topic originator
public final class Member: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum MemberCodingKeys: String, CodingKey {
        case id, email
        case firstName = "firstname"
        case lastName = "lastname"
        case avatarURL = "avatarUrl"
    }

    // MARK: - Initializer

    /// Used to create a 'Member' managed object
    /// - Parameters:
    ///   - oktaID: the user's current Okta Bearer Token (only used for login)
    ///   - id: defaults to new UUID, make sure to assign the correct one when decoding
    ///   rather than generating a new one
    ///   - email: optional, used for login and updating email only (defaults to nil)
    ///   - firstName: optional, used for registration and updating name only (defaults to nil)
    ///   - lastName: optional, used for registration and updating name only (defaults to nil)
    ///   - avatarURL: optional, used for displaying the user's profile image
    @discardableResult convenience init(oktaID: String?,
                                        id: Int64?,
                                        email: String?,
                                        firstName: String?,
                                        lastName: String?,
                                        avatarURL: URL?,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.oktaID = oktaID
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
    }

    /// Used to create managed objects by way of decoding
    /// Manual decoding to handle same key used for different properties
    /// ```
    /// let jsonDecoder = JSONDecoder()
    /// jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataManager.shared.mainContext
    /// let topic = try! jsonDecoder.decode(Topic.self, from: mockJsonData)
    /// ```
    public required convenience init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw ErrorHandler.DecoderConfigurationError.missingManagedObjectContext
        }

        self.init(context: moc)

        let container = try decoder.container(keyedBy: MemberCodingKeys.self)
        // if id is Int, this is a web user ID
        id = try? container.decode(Int64.self, forKey: .id)
        // if id is String, this is an Okta ID
        if id == nil {
            oktaID = try? container.decode(String.self, forKey: .id)
        }

        email = try? container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        avatarURL = try container.decode(URL.self, forKey: .avatarURL)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: MemberCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(email, forKey: .email)
        try container.encode(firstName, forKey: .firstName)
        try container.encode(lastName, forKey: .lastName)
        try container.encode(avatarURL, forKey: .avatarURL)
    }

    // MARK: - Equatable Conformance -

    // FIXME: - This may be redundant? Not sure. Revisit later.
    static func == (lhs: Member, rhs: Member) -> Bool {
        lhs.oktaID == rhs.oktaID
    }
}
