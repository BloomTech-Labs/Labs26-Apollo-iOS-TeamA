// Copyright © 2020 Shawn James. All rights reserved.
// ResponseMO.swift

import CoreData

final public class ResponseMO: NSManagedObject, Codable {
    
    // MARK: - Coding Keys
    
    enum ResponseMOCodingKeys: CodingKey {
        case id, questionId, response
    }
    
    // MARK: - Initializers
    
    /// Used to create managed object
    @discardableResult convenience init(id: UUID,
                                        questionId: UUID,
                                        response: String,
                                        context: NSManagedObjectContext = CoreDataManager.shared.mainContext) {
        self.init(context: context)
        self.id = id
        self.questionId = questionId
        self.response = response
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
        
        let container = try decoder.container(keyedBy: ResponseMOCodingKeys.self)
        
        self.id = try container.decode(UUID.self, forKey: .id)
        self.questionId = try container.decode(UUID.self, forKey: .questionId)
        self.response = try container.decode(String.self, forKey: .response)
    }
    
    /// Used for encoding
    /// ```
    ///  let jsonEncoder = JSONEncoder()
    ///  let topic = TopicMO(identifier: 1, leaderID: 7, joinCode: "JoinCode123", topicName: "This is a topic name")
    ///  let jsonData = try jsonEncoder.encode(topic)
    /// ```
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: ResponseMOCodingKeys.self)
        
        try container.encode(id, forKey: .id)
        try container.encode(questionId, forKey: .questionId)
        try container.encode(response, forKey: .response)
    }
    
}
