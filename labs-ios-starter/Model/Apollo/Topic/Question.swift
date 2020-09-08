//
//  Question.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct Question: Codable {
    var id: UUID
    var question: String //questions? need final backend model
    var type: String
    var style: String //for rating
    var context: ContextQuestion?
}
