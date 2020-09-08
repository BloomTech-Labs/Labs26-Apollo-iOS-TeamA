//
//  Topic.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct Topic: Codable {
    var id: UUID // needs to be same type as identifier/token/etc - see above comment
    var joinCode: String // can this be the ID actually?
    var leaderId: UUID
    var members: [Member]?

    var topicName: String // is this changeable? if not, change to constant
    var contextQuestion: Question
    var requestQuestion: [Question] //if we change this to requestQuestions, we'll need a coding key
    var responses: [Response]

    var contextId: Int // do we need this?
}
