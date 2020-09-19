//
//  Topic.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

///Leaders can post topics, members join with a `joinCode`
struct Topic: Codable {

    // MARK: - Coding Keys -
    enum CodingKeys: String, CodingKey {
        case id
        case joinCode = "joincode"
        case leaderId = "leaderid"
        case members
        case topicName = "topicname"
        case contextId = "contextid"
        case responsesToSend = "responses"
        case questionsToSend = "questions"
    }

    var id: Int?
    //required to create
    var joinCode: String?
    var leaderId: String
    var members: [Member]?
    var topicName: String
    var contextId: Int?

    // MARK: App use
    //doesnt get sent
    var questions: [Question]?
    //coding key assigned
    var questionsToSend: [Int]?
    //doesn't get sent
    var responses: [Response]?
    //coding key assigned
    var responsesToSend: [Int]?

}
