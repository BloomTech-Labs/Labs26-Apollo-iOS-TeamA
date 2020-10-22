//
//  TemporaryObjects.swift
//  labs-ios-starter
//
//  Created by Kenny on 10/22/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

// MARK: - Codable Types -

struct ContextResponseObject: Codable {
    enum CodingKeys: String, CodingKey {
        case surveyId = "surveyrequestid"
        case contextQuestionId = "contextquestionid"
        case response
    }

    let surveyId: Int64
    let contextQuestionId: Int64
    let response: String
}

/// Used to get Topic Details and establish CoreData Relationships
struct TopicDetails: Codable {
    enum CodingKeys: String, CodingKey {
        case details = "0"
        case contextQuestionIds = "contextquestions"
        case requestQuestionIds = "requestquestions"
    }

    var details: TopicDetailObject
    var contextQuestionIds: [ContextQuestionObject]
    var requestQuestionIds: [RequestQuestionObject]
}

/// Represent's a contextQuestion's id
struct ContextQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case contextQuestionId = "contextquestionid"
    }

    let contextQuestionId: Int
}

/// Represent's a requestQuestion's id
struct RequestQuestionObject: Codable {
    enum CodingKeys: String, CodingKey {
        case requestQuestionId = "requestquestionid"
    }

    let requestQuestionId: Int
}

enum QuestionType {
    case context
    case request
}

/// Used to get related context and resquest questions
struct TopicDetailObject: Codable {
    enum CodingKeys: String, CodingKey {
        case joinCode = "joincode"
        case id
        case contextId = "contextid"
        case leaderId = "leaderid"
        case topicName = "topicname"
    }

    let joinCode: String
    let id: Int
    let contextId: Int
    let leaderId: String
    let topicName: String
}

/// Used to get topic ID after sending to backend
struct TopicID: Codable {
    let topic: DecodeTopic
}

/// Member of TopicID
struct DecodeTopic: Codable {
    let id: Int
}

/// Used to encode topic and question id in order to establish their relationship in the backend
struct TopicQuestion: Codable {
    enum CodingKeys: String, CodingKey {
        case topicId = "topicid"
        case questionId = "questionid"
    }

    var topicId: Int
    var questionId: Int
}
