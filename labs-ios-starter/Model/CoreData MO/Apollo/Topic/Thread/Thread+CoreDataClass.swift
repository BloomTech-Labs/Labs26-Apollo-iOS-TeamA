//
//  Thread+CoreDataClass.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/20/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData

/// AKA Threads - users can respond to Questions
public final class Thread: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum ThreadCodingKeys: String, CodingKey {
        case id, reply
        case responseId = "responseid"
        case response
        case repliedBy = "repliedby"
        case contextResponse = "contextResponse"
    }

    // MARK: - Initializers

    /// Used to create managed object
    @discardableResult convenience init(id: Int64,
                                        responseId: Int64,
                                        reply: String,
                                        repliedBy: Member,
                                        contextResponse: ContextResponse,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.responseId = responseId
        self.repliedBy = repliedBy.id
        self.contextResponse = contextResponse
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

        let container = try decoder.container(keyedBy: ThreadCodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        responseId = try container.decode(Int64.self, forKey: .responseId)
        contextResponse = try container.decode(ContextResponse.self, forKey: .response)
        repliedBy = try container.decode(String.self, forKey: .repliedBy)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ThreadCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(responseId, forKey: .responseId)
        try container.encode(repliedBy, forKey: .repliedBy)
        try container.encode(contextResponse, forKey: .contextResponse)
    }
}

