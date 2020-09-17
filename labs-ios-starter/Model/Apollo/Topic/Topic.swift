//
//  Topic.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

///Leaders can post topics
struct Topic: Codable {
    var id: Int?
    //required to create
    var joinCode: String?
    var leaderId: String
    var members: [Member]?
    var topicName: String
    var contextId: Int?

    //App use
    //doesnt get sent
    var questions: [Question]?
    //coding key assigned
    var questionsToSend: [Int]?
    //doesn't get sent
    var responses: [Response]?
    //coding key assigned
    var responsesToSend: [Int]?


    enum CodingKeys: String, CodingKey {
        case id
        case joinCode
        case leaderId
        case members
        case topicName
        case contextId
        case responsesToSend = "responses"
        case questionsToSend = "questions"
    }

}
