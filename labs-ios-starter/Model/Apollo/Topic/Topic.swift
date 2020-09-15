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
    var id: Int
    //required to create
    var joinCode: String
    var leaderId: Int
    var members: [Member]?
    var topicName: String
    var contextId: Int

    //App use
    var questions: [Question]
    var responses: [Response]

}
