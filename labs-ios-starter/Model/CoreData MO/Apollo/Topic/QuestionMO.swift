// Copyright © 2020 Shawn James. All rights reserved.
// QuestionMO.swift

import CoreData

final public class QuestionMO: NSManagedObject, Codable {
    
    // MARK: - Coding Keys
    
    enum QuestionMOCodingKeys: CodingKey {
        case id, question, style, type
    }
    
    // MARK: - Initializers
    
    /// Used to create managed object
    @discardableResult convenience init(id: UUID,
                                        question: String,
                                        style: String,
                                        type: String,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.question = question
        self.style = style
        self.type = type
    }
    
    /// Used to create managed objects by way of decoding
    /// ```
    /// let jsonDecoder = JSONDecoder()
    /// jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataManager.shared.mainContext
    /// let topic = try! jsonDecoder.decode(TopicMO.self, from: mockJsonData)
    /// ```
    required convenience public init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw ErrorHandler.DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: moc)
        
        let container = try decoder.container(keyedBy: QuestionMOCodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.question = try container.decode(String.self, forKey: .question)
        self.style = try container.decode(String.self, forKey: .style)
        self.type = try container.decode(String.self, forKey: .type)

    }
    
    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = TopicMO(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: QuestionMOCodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(question, forKey: .question)
        try container.encode(style, forKey: .style)
        try container.encode(type, forKey: .type)
    }
    
}
