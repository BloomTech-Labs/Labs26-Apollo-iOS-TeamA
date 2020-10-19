// Copyright © 2020 Shawn James. All rights reserved.
// Question+CoreDataClass.swift
//

import CoreData

/// Leaders and users can ask questions
public final class ContextQuestion: NSManagedObject, Codable {
    // MARK: - Coding Keys

    enum QuestionCodingKeys: String, CodingKey {
        case id
        case question
        //case reviewType = "type"
        case ratingStyle = "style"
        // case contextId = "contextid"
        case template = "default"
    }

    // MARK: - Initializer

    /// Used to create managed object
    @discardableResult convenience init(id: Int64,
                                        question: String,
                                        reviewType: String,
                                        ratingStyle: String,
                                        template: Bool,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.question = question
        self.reviewType = reviewType
        self.ratingStyle = ratingStyle
        self.template = template
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

        let container = try decoder.container(keyedBy: QuestionCodingKeys.self)

        id = try container.decode(Int64.self, forKey: .id)
        question = try container.decode(String.self, forKey: .question)
        //reviewType = try container.decode(String.self, forKey: .reviewType)
        ratingStyle = try container.decode(String.self, forKey: .ratingStyle)
        template = try container.decode(Bool.self, forKey: .template)
    }

    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = Topic(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: QuestionCodingKeys.self)

        try container.encode(id, forKey: .id)
        try container.encode(question, forKey: .question)
        try container.encode(template, forKey: .template)
        //try container.encode(reviewType, forKey: .reviewType)
        try container.encode(ratingStyle, forKey: .ratingStyle)
    }
}
