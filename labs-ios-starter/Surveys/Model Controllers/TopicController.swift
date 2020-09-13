//
//  TopicController.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

class TopicController {
    let networkService = NetworkService.shared
    let baseURL = ProfileController.shared.baseURL

    private func createRequest(auth: Bool = true,
                               pathFromBaseURL: String,
                               method: NetworkService.HttpMethod = .get) -> URLRequest? {

        let targetURL = baseURL.appendingPathComponent(pathFromBaseURL)

        guard var request = networkService.createRequest(url: targetURL, method: method) else {
            print("unable to create request for \(targetURL)")
            return nil
        }

        if auth {
            //add bearer to request
            request.addAuthIfAvailable()
        }

        return request
    }

    func fetchTopic(all: Bool = true) {
        var appendToURL = "topic"
        if !all {
            // Doesn't look like this will work - topic by id is topic id
            // TODO: coordinate with BE team to see if we can get a topic by userId endpoint
            appendToURL = ProfileController.shared.authenticatedUserProfile!.id!
        }
        guard let request = createRequest(pathFromBaseURL: appendToURL) else {
            return
        }
        
        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                print(self.networkService.decode(to: [Topic].self, data: data))
            case .failure(let error):
                print(error)
            }
        }
    }

    func getAllContexts() {

    }

    func postTopic() {
        guard var request = createRequest(pathFromBaseURL: "topic", method: .post) else {
            return
        }

        //TODO: Dynamic topic
        let json = """
                   {
                    "topicname":"Test"
                    }
                   """.data(using: .utf8)!
        request.addJSONData(json)

        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                print(data)
            case .failure(let error):
                print(error)
            }
        }
    }
}




