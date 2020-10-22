//
//  CoreDataTests.swift
//  labs-ios-starterTests
//
//  Created by Kenny on 9/22/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData
@testable import labs_ios_starter
import XCTest

class CoreDataTests: XCTestCase {
    let fetchController = FetchController()

    override func setUpWithError() throws {
        // MARK: Setup Topic
        let member = Member(id: "Test1",
                            email: "test1@test.com",
                            firstName: "Test",
                            lastName: "Member",
                            avatarURL: URL(string: "http://devgauge.com"))
        let members = NSSet().adding(member) as NSSet

        let topic = Topic(id: 999, joinCode: "join1", leaderId: member.id!, members: members, topicName: "TestTopic", contextId: 2)

        // MARK: Setup ContextQuestion and ContextResponse
        let contextQuestion = ContextQuestion(id: 999, question: "What is your major malfunction?", reviewType: "stars", ratingStyle: "", template: false)

        topic.addToContextQuestions(contextQuestion)

        let response = ContextResponse(id: 999, questionId: contextQuestion.id, response: "IDK, why don't we go to HR and find out", respondedBy: member, contextQuestion: contextQuestion)

        contextQuestion.addToResponse(response)
        do {
            try CoreDataManager.shared.saveContext()
        } catch {
            XCTFail("error saving CoreData: \(error)")
        }


    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testCanSaveAndFetchTopic() {
        let fetchedTopics = fetchController.fetchLeaderTopics(with: [999])
        XCTAssertEqual(fetchedTopics?.count, 1)
    }

    func testCanEstablishMemberRelationship() {
        let fetchedTopics = fetchController.fetchLeaderTopics(with: [999])
        let members = fetchedTopics?[0].members
        XCTAssertNotNil(members)
        XCTAssertTrue(members!.count > 0)
    }

    func testCanEditTopicWithExternalChange() {
        let fetchedTopic = fetchController.fetchLeaderTopics(with: [999])?.first
        let name = fetchedTopic?.topicName
        XCTAssertNotNil(name)
        fetchedTopic?.topicName = "Changed It"
        XCTAssertNotEqual(name, fetchedTopic?.topicName)
    }

    func testCanEstablishQuestionToTopicRelationship() {
        let fetchedTopic = fetchController.fetchLeaderTopics(with: [999])?[0]

        guard let fetchedQuestions = fetchController.fetchDefaultContextQuestionsRequest() else {
            XCTFail("Couldn't unwrap fetched questions")
            return
        }

        fetchedTopic?.addToContextQuestions(NSSet(array: fetchedQuestions))
        XCTAssertNotNil(fetchedTopic?.contextQuestions)
        XCTAssertEqual(fetchedTopic?.contextQuestions?.count, 3)
    }

    func testCanCreateContextResponseInContextQuestion() {
        let fetchedQuestion = fetchController.fetchContextQuestionsRequest(topicId: 999)![0]
        let fetchedResponse = fetchController.fetchContextResponseRequest(contextQuestionId: fetchedQuestion.id)![0]

        XCTAssertEqual(fetchedQuestion.responses.count, 1)
        XCTAssertNotNil(fetchedResponse)
    }

    func testCanCreateThreadInContextResponse() {

        let fetchedResponse = fetchController.fetchContextResponseRequest(contextQuestionId: 999)![0]
        let thread = Thread(id: 999, responseId: fetchedResponse.id, reply: "Hey calm down", repliedBy: Member(id: "999", email: "", firstName: "", lastName: "", avatarURL: nil), contextResponse: fetchedResponse)

        fetchedResponse.addToThreads(thread)

        XCTAssertEqual(fetchedResponse.threads.count, 1)
        XCTAssertEqual(thread.contextResponse, fetchedResponse)
    }
}
