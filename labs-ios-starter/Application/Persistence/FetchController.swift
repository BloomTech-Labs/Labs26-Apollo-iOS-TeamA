//
//  FetchController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/22/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import CoreData
import Foundation

class FetchController {
    // MARK: - Properties -
    let profileController = ProfileController.shared

    // MARK: - Topic Fetch Requests -

    /// Fetches [Topic] from CoreData based on predicate
    /// - Parameters:
    ///   - predicate: NSPredicate used to filter CoreData results
    ///   - context: The context used to execute the request (no default)
    /// - Returns: An array of Topic if the fetch succeeds, nil if it fails
    private func fetchTopicRequest(with predicate: NSPredicate, context: NSManagedObjectContext) -> [Topic]? {
        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()

        fetchRequest.predicate = predicate
        do {
            let topics = try context.fetch(fetchRequest)
            return topics
        } catch let fetchError {
            print("Error Fetching Topics user is a Leader of: \(fetchError)")
            return nil
        }
    }

    /// Fetches the topic with the matching id
    /// - Parameters:
    ///   - id: Int64 - must match TopicID
    ///   - context: The context used to execute the request
    /// - Returns: The first topic found matching the passed in ID (it's constrained so there can only be 1, but the helper method is set up to fetch an array
    func fetchTopic(with id: Int64, context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> Topic? {
        let predicate = NSPredicate(format: "id == %d", id)
        return fetchTopicRequest(with: predicate, context: context)?.first
    }

    /// Fetches [Topic] from CoreData where the currently logged in user matches the Topic's leaderId
    /// - Parameters:
    ///   - identifiersToFetch: The identifiers of Topics to attempt to retrieve from CoreData
    ///   - context: The context used to execute the request
    /// - Returns: An array of Topic on success, or nil on failure
    func fetchLeaderTopics(with identifiersToFetch: [Int], context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [Topic]? {
        guard let userID = profileController.authenticatedUserProfile?.id else {
            print("user not logged in, testing")
            let userID = "Test1"
            let predicate = NSPredicate(format: "id IN %@ AND leaderId == %@", identifiersToFetch, userID)
            return fetchTopicRequest(with: predicate, context: context)
        }
        let predicate = NSPredicate(format: "id IN %@ AND leaderId == %@", identifiersToFetch, userID)

        return fetchTopicRequest(with: predicate, context: context)
    }

    /// Fetches [Topic] from CoreData where the currently logged in user matches a member in the Topic
    /// - Parameters:
    ///   - identifiersToFetch: The identifiers of Topics to attempt to retrieve from CoreData
    ///   - context: The context used to execute the request
    /// - Returns: An array of Topic on success, or nil on failure
    func fetchMemberTopics(with identifiersToFetch: [Int], context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [Topic]? {
        guard let user = profileController.authenticatedUserProfile else {
            print("user not logged in")
            return nil
        }

        // TODO: Test
        // need predicate for id IN identifiersToFetch AND userId IN Topic.members.map { $0.id }
        // (member in Topic.members)
        let predicate = NSPredicate(format: "id IN %@ AND %@ IN members", identifiersToFetch, user)

        return fetchTopicRequest(with: predicate, context: context)
    }

    func fetchTopicsNotOnServer(_ ids: [Int64], context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [Topic]? {
        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()

        let predicate = NSPredicate(format: "NOT (id IN %@)", ids)
        fetchRequest.predicate = predicate
        do {
            let topics = try context.fetch(fetchRequest)
            return topics
        } catch let fetchError {
            print("Error fetching Topics: \(fetchError)")
            return nil
        }
    }

    // MARK: - Context Fetch Requests -
    func fetchContextRequest(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [ContextObject]? {
        let fetchRequest: NSFetchRequest<ContextObject> = ContextObject.fetchRequest()

        do {
            let contexts = try context.fetch(fetchRequest)
            return contexts
        } catch let fetchError {
            print("Error Fetching Contexts: \(fetchError)")
            return nil
        }
    }

    // MARK: - Question Fetch Requests -
    /// fetch all context questions for a Topic
    func fetchContextQuestionsRequest(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [ContextQuestion]? {
        let fetchRequest: NSFetchRequest<ContextQuestion> = ContextQuestion.fetchRequest()

        do {
            let questions = try context.fetch(fetchRequest)
            return questions
        } catch let fetchError {
            print("Error Fetching Questions: \(fetchError)")
            return nil
        }
    }

    func fetchDefaultContextQuestionsRequest(context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [ContextQuestion]? {
        let fetchRequest: NSFetchRequest<ContextQuestion> = ContextQuestion.fetchRequest()
        let predicate = NSPredicate(format: "template == true")
        fetchRequest.predicate = predicate

        do {
            let questions = try context.fetch(fetchRequest)
            return questions
        } catch let fetchError {
            print("Error Fetching Questions: \(fetchError)")
            return nil
        }
    }

    /// fetch all request questions for a Topic
    func fetchRequestQuestionsRequest(topicId: Int64, context: NSManagedObjectContext = CoreDataManager.shared.mainContext) -> [RequestQuestion]? {
        let fetchRequest: NSFetchRequest<RequestQuestion> = RequestQuestion.fetchRequest()
        let predicate = NSPredicate(format: "topic.id == %@", topicId)
        fetchRequest.predicate = predicate
        do {
            let questions = try context.fetch(fetchRequest)
            return questions
        } catch let fetchError {
            print("Error Fetching Questions: \(fetchError)")
            return nil
        }
    }

}
