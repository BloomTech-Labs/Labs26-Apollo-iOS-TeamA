//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/10/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

class TopicController {
    var topics: [Topic] = []
    ///can replace with standard predicate if not using array
//    var leaderTopics: [Topic] {
//        topics.filter { $0.leaderId == currentUserId } //currentUserId will be userId of currently logged in user (static in AuthService maybe)
//    }
    ///can replace with standard predicate if not using array
//    var memberTopics: [Topic] {
//        topics.filter { $0.leaderId != currentUserId } //currentUserId will be userId of currently logged in user (static in AuthService maybe)
//    }

    ///return array of topics, or fill array of topics?
    func getTopics() {

        // send userID to backend (other param if req) {
             // Receive array of topics with user as leader and member
            // sync with CoreData
        // }

    }

    /// This will be called at the end of the create topic flow (after user picks all required variables)
//    func createTopic() -> Topic {
//
//        // send required parameters to create topic to backend {
//            // receive id and joinCode
//            // save in CoreData
//            // add to array (if that even makes sense since we're using CoreData - can just fetch)
//        // }
//
//    }

    func deleteTopic() {

        //send required parameters (probably just TopicID) to backend
            //delete from coredata
            //remove from array (if being used)

    }

    func updateTopic(_ topic: Topic) {
        //send updated parameters with required parameters to backend
            //update in coredata
            //update in array (if being used)
    }

    /// Any member requests a new leader for the topic
    func proposeLeaderChange(for topic: Topic, with newLeader: Member, isLeaderBeingNotified: Bool) {

        if isLeaderBeingNotified {
            // notify current leader that change is being requested
            // leader gets modal with accept/deny
            // if leader accepts, trigger this method again with isLeaderBeingNotified: false
        } else {
            // notify member they are being proposed as leader
            // user gets modal with accept/deny
            // trigger leaderChangeAccepted(true/false)
        }
    }

    /// new member accepted request, notification received to trigger this
    func leaderChangeAccepted(for topic: Topic, by newLeader: Member, accepted: Bool) {
        if accepted {
            // notify all members of leadership change
            // changeLeader()
        } else {
            // notify leader that request was denied
        }
    }

    ///trigger after receiving confirmation from leader and new member
    func changeLeader(of topic: Topic, with newLeader: Member) {

        // updateTopic()

    }
}
