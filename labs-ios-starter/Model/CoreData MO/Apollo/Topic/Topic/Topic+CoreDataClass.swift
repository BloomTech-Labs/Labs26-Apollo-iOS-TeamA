// Copyright © 2020 Shawn James. All rights reserved.
// Topic+CoreDataClass.swift
//

import CoreData

/// Leaders can post topics, members join with a `joinCode`
public final class Topic: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum TopicCodingKeys: String, CodingKey {
        case id, members
        case joinCode = "joincode"
        case leaderId = "leaderid"
        case topicName = "topicname"
        case contextId = "contextid"
        case responsesToSend = "responses"
        case questionsToSend = "questions"
    }

    // MARK: - Initializer

    /// Used to create managed object
    @discardableResult convenience init(id: Int64? = nil,
                                        joinCode: String?,
                                        leaderId: String,
                                        members: NSSet? = nil,
                                        topicName: String,
                                        contextId: Int64?,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.joinCode = joinCode
        self.leaderId = leaderId
        self.members = members
        self.topicName = topicName
        self.contextId = contextId
        self.topicName = topicName
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

        let container = try decoder.container(keyedBy: TopicCodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        joinCode = try container.decode(String.self, forKey: .joinCode)
        leaderId = try container.decode(String.self, forKey: .leaderId)
        topicName = try container.decode(String.self, forKey: .topicName)
        contextId = try container.decode(Int64.self, forKey: .contextId)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: TopicCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(joinCode, forKey: .joinCode)
        try container.encode(leaderId, forKey: .leaderId)
        try container.encode(topicName, forKey: .topicName)
        try container.encode(contextId, forKey: .contextId)
    }
}
