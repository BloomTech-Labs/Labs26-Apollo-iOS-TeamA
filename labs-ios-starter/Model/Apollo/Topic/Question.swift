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
    var id: Int
    //var contextId: Int
    var question: String
    var reviewType: String
    var ratingStyle: String


    enum CodingKeys: String, CodingKey {
        case id
        //case contextId = "contextid"
        case question
        case reviewType = "type"
        case ratingStyle = "style"
    }
}
