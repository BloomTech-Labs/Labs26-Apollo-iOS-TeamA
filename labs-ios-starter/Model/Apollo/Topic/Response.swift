//
//  Response.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct Response: Codable {
    var id: UUID
    var question: Question
    var response: String
    var respondedBy: Member
    var topic: Topic

}
