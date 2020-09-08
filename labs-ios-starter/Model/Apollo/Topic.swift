//
//  Topic.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct Topic: Codable {
    var leaderId: UUID // needs to be same type as identifier/token/etc
    var id: UUID // see above comment
    var topicName: String // is this changeable? if not, change to constant
    var contextQuestion: String
    var requestQuestion: String
    var joinCode: String
    var contextId: Int
}
