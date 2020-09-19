// Copyright © 2020 Shawn James. All rights reserved.
// Topic.swift

import CoreData

final public class Topic: NSManagedObject, Codable {
    
    // MARK: - Coding Keys
    
    enum TopicCodingKeys: CodingKey {
        case id, joinCode, leaderId, topicName
    }
    
    // MARK: - Initializers
    
    /// Used to create managed object
    @discardableResult convenience init(id: UUID,
                                        joinCode: String,
                                        leaderId: UUID,
                                        topicName: String,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.leaderId = leaderId
        self.joinCode = joinCode
        self.topicName = topicName
    }
    
    /// Used to create managed objects by way of decoding
    /// ```
    /// let jsonDecoder = JSONDecoder()
    /// jsonDecoder.userInfo[CodingUserInfoKey.managedObjectContext] = CoreDataManager.shared.mainContext
    /// let topic = try! jsonDecoder.decode(Topic.self, from: mockJsonData)
    /// ```
    required convenience public init(from decoder: Decoder) throws {
        guard let moc = decoder.userInfo[CodingUserInfoKey.managedObjectContext] as? NSManagedObjectContext else {
            throw ErrorHandler.DecoderConfigurationError.missingManagedObjectContext
        }
        self.init(context: moc)
        
        let container = try decoder.container(keyedBy: TopicCodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.joinCode = try container.decode(String.self, forKey: .joinCode)
        self.leaderId = try container.decode(UUID.self, forKey: .leaderId)
        self.topicName = try container.decode(String.self, forKey: .topicName)
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
    }
    
}
