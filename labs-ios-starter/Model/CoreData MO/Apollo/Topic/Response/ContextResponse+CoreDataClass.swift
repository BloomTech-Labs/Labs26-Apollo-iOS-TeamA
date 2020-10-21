// Copyright © 2020 Shawn James. All rights reserved.
// Response+CoreDataClass.swift
//

import CoreData

/// AKA Threads - users can respond to Questions
public final class ContextResponse: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum ContextResponseCodingKeys: String, CodingKey {
        case id,
             response,
             respondedBy,
             topic
        case questionId = "questionid"
    }

    // MARK: - Initializers

    /// Used to create managed object
    @discardableResult convenience init(id: Int64,
                                        questionId: Int64,
                                        response: String,
                                        respondedBy: Member,
                                        contextQuestion: ContextQuestion,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.questionId = questionId
        self.response = response
        self.respondedBy = respondedBy
        self.contextQuestion = contextQuestion
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

        let container = try decoder.container(keyedBy: ContextResponseCodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        questionId = try container.decode(Int64.self, forKey: .questionId)
        response = try container.decode(String.self, forKey: .response)
        respondedBy = try container.decode(Member.self, forKey: .respondedBy)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContextResponseCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(questionId, forKey: .questionId)
        try container.encode(response, forKey: .response)
        try container.encode(respondedBy, forKey: .respondedBy)
        // encode contextQuestion?
    }
}
