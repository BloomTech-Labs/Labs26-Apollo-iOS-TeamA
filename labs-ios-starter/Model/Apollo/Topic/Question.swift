//
//  Question.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//


//Leaders and users can ask questions
import Foundation

//It seems like questions should have responses...
struct Question: Codable {
    var id: UUID
    var question: String //questions? need final backend model
    var type: String
    var style: String //for rating
    var context: ContextObject?
}
