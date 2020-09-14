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

    var contexts: [String: ContextObject]  {
        CONTEXTS
    }

    private var CONTEXTS: [String:ContextObject] = [:]

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
            appendToURL = "\(ProfileController.shared.authenticatedUserProfile!.id!)"
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
    typealias CompleteWithContextQuestions = (Result<[ContextObject], ErrorHandler.NetworkError>) -> Void
    func getAllContexts(complete: @escaping CompleteWithContextQuestions) {
        guard let request = createRequest(pathFromBaseURL: "context") else {
            print("couldn't get context, invalid request")
            return
        }
        networkService.loadData(using: request) { result in
            switch result {
            case .success(let data):
                guard let contexts = self.networkService.decode(to: [ContextObject].self, data: data) else {
                    print("error decoding contexts from valid data")
                    complete(.failure(.notFound))
                    return
                }
                complete(.success(contexts))
            case .failure(let error):
                complete(.failure(error))
            }
        }
    }

    typealias CompleteWithContextQuestion = (Result<ContextObject, ErrorHandler.NetworkError>) -> Void
    func getQuestion(with contextID: String, completion: @escaping CompleteWithContextQuestion) {

        getAllContexts() { result in
            guard let question = self.contexts[contextID] else {
                print("context with ID not found")
                completion(.failure(.notFound))
                return
            }
            completion(.success(question))
        }


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




