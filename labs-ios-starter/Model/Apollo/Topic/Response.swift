//
//  Response.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

/// AKA Threads - users can respond to Questions
struct Response: Codable {
    var id: UUID
    var questionId: UUID
    var response: String
    var respondedBy: Member
    var topic: Topic
}
