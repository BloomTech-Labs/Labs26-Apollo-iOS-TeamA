// Copyright © 2020 Shawn James. All rights reserved.
// ContextObject+CoreDataClass.swift
//

import CoreData

/// Used to determine a Question's context. so named to avoid collision with Swift.Context
public final class ContextObject: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum ContextObjectCodingKeys: String, CodingKey {
        case id
        case title = "contextoption"
    }

    // MARK: - Initializer

    /// Used to create managed object
    @discardableResult convenience init(id: Int64,
                                        title: String,
                                        moc: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: moc)
        self.id = id
        self.title = title
    }

    /// Used to create managed objects by way of decoding
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

        let container = try decoder.container(keyedBy: ContextObjectCodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContextObjectCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
    }
}
