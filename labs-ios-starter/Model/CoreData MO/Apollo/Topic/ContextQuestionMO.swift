// Copyright © 2020 Shawn James. All rights reserved.
// ContextQuestionMO.swift

import CoreData

final public class ContextQuestionMO: NSManagedObject, Codable {
    
    // MARK: - Coding Keys
    
    enum ContextQuestionMOCodingKeys: CodingKey {
        case id, context
    }
    
    // MARK: - Initializers
    
    /// Used to create managed object
    @discardableResult convenience init(id: UUID,
                                        context: [String],
                                        moc: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: moc)
        self.id = id
        self.context = context
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
        
        let container = try decoder.container(keyedBy: ContextQuestionMOCodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.context = try container.decode([String].self, forKey: .context)
    }
    
    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = TopicMO(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ContextQuestionMOCodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(context, forKey: .context)
    }
    
}
