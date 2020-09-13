//
//  NetworkService.swift
//  NetworkScaffold
//
//  Created by Kenny on 9/2/20.
//  Copyright © 2020 Kenny Dubroff. All rights reserved.
//

import Foundation

/// Standard URL Handler that can be used in Unit Tests with mock data
typealias URLHandler = (Data?, HTTPURLResponse?, Error?) -> Void
/// Completion Handler using ErrorHandler class to handle common errors
typealias URLCompletion = ((Result<Data, ErrorHandler.NetworkError>) -> Void)

protocol NetworkLoader {
    func loadData(using request: URLRequest, with completion: @escaping URLCompletion)
}

// TODO: Improve error handling
/// Provide default error and response handling for network tasks
extension URLSession: NetworkLoader {

    func loadData(using request: URLRequest, with completion: @escaping URLCompletion) {
        self.dataTask(with: request) { (data, response, error) in
            //downcast response to HTTPURLResponse to work with the statusCode
            if let httpResponse = response as? HTTPURLResponse {
                let statusCode = httpResponse.statusCode

                if statusCode != 200 {
                    //unwrap the handled exception, or log an unhandled exception
                    guard let statusError = ErrorHandler.NetworkError(rawValue: statusCode) else {
                        // Edge case - unhandled exception (if this is logged, the ErrorHandler likely needs to be extended)
                        NSLog("unhandled exception \(statusCode) from \(HTTPURLResponse.localizedString(forStatusCode: statusCode))")
                        completion(.failure(.unknown))
                        return
                    }
                    //log and complete with the error to be further handled by the caller
                    NSLog("\(#file).\(#function) completed with error: \(statusError)\ndescription: \(HTTPURLResponse.localizedString(forStatusCode: statusCode))")
                    completion(.failure(statusError))
                    return
                }

            }

            if let error = error {
                // Edge case - standard networking error not handled in response, or no response
                NSLog("Networking error in \(#file).\(#function) with \(String(describing: request.url?.absoluteString)) \n\(error)")
                completion(.failure(.unknown))
            }

            guard let data = data else {
                // Edge case - if no error and valid response, why no data?
                let response = response as? HTTPURLResponse
                NSLog("unhandled exception in \(#file).\(#function) - NIL DATA WITH RESPONSE: \(String(describing: response?.statusCode))")
                completion(.failure(.unknown))
                return
            }
            completion(.success(data))
        }.resume()
    }
}

class NetworkService {

    // MARK: - Pseudo Singleton -
    // (init not private to allow for Mock Data Testing) -
    /// Singleton for production use, use standard init in testing
    static let shared = NetworkService()

    // MARK: - Types -

    ///Used to set a`URLRequest`'s HTTP Method
    enum HttpMethod: String {
        case get = "GET"
        case patch = "PATCH"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }

    /**
     used when the endpoint requires a header-type (i.e. "content-type") be specified in the header
     */
    enum HttpHeaderType: String {
        case contentType = "Content-Type"
        case authorization = "Authorization"
    }

    /**
     the value of the header-type (i.e. "application/json")
     */
    enum HttpHeaderValue: String {
        case json = "application/json"
    }

    /**
     - parameter request: should return nil if there's an error or a valid request object if there isn't
     - parameter error: should return nil if the request succeeded and a valid error if it didn't
     */
    struct EncodingStatus {
        let request: URLRequest?
        let error: Error?
    }

    // MARK: - Properties -
    var errorHandler = ErrorHandler.shared
    ///used to switch between live and Mock Data
    var dataLoader: NetworkLoader

    //MARK: - Init -
    ///defaults to URLSession implementation
    init(dataLoader: NetworkLoader = URLSession.shared) {
        self.dataLoader = dataLoader
    }

    ///for json encoding/decoding (can be modified to meet specific criteria)
    var dateFormatter: DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .short
        return dateFormatter
    }

    /**
     Create a request given a URL and requestMethod (GET, POST, CREATE, etc...)
     */
    func createRequest(
        url: URL?, method: HttpMethod,
        headerType: HttpHeaderType? = nil,
        headerValue: HttpHeaderValue? = nil
    ) -> URLRequest? {
        guard let requestUrl = url else {
            NSLog("request URL is nil")
            return nil
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        if let headerType = headerType,
            let headerValue = headerValue {
            request.setValue(headerValue.rawValue, forHTTPHeaderField: headerType.rawValue)
        }
        return request
    }

    func decode<T: Decodable>(
        to type: T.Type,
        data: Data,
        dateFormatter: DateFormatter? = nil
    ) -> T? {
        let decoder = JSONDecoder()
        //for optional dateFormatter
        if let dateFormatter = dateFormatter {
            decoder.dateDecodingStrategy = .formatted(dateFormatter)
        }
        //avoid using Coding Keys
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            print("Error Decoding JSON into \(String(describing: type)) Object \(error)")
            return nil
        }
    }

    func loadData(using request: URLRequest, with completion: @escaping URLCompletion) {
        self.dataLoader.loadData(using: request, with: completion)
    }

}
