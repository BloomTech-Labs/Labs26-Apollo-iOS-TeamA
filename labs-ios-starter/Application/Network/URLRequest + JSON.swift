//
//  URLRequest + JSON.swift
//  NetworkScaffold
//
//  Created by Kenny on 9/2/20.
//  Copyright © 2020 Kenny Dubroff. All rights reserved.
//

import Foundation

extension URLRequest {
    /// Add .utf8 encoded data (JSON) to a URLRequest
    /// - Parameters:
    ///   - request: URLRequest will be unwrapped in body. This will return an error. The original request won't be modified
    ///   - data: Must be encoded in .utf8
    /// - Returns: an EncodingStatus object with a mutated request and nil error or error and nil request
    mutating func addJSONData(_ data: Data) {

        if self.httpBody != nil {
            self.httpBody!.append(data)
        } else {
            self.httpBody = data
        }

    }

    /**
     Encode from a Swift object to JSON for transmitting to an endpoint
     - parameter type: the type to be encoded (i.e. MyCustomType.self)
     - parameter request: the URLRequest used to transmit the encoded result to the remote server. The original request won't be modified
     - parameter dateFormatter: optional for use with JSONEncoder.dateEncodingStrategy
     - returns: An EncodingStatus object which should either contain an error and nil request or request and nil error
     */
    mutating func encode<T: Encodable>(
        from encodable: T,
        dateFormatter: DateFormatter? = nil
    ) {
        let jsonEncoder = JSONEncoder()
        //avoid using Coding Keys
        jsonEncoder.keyEncodingStrategy = .convertToSnakeCase
        //for optional dateFormatter
        if let dateFormatter = dateFormatter {
            jsonEncoder.dateEncodingStrategy = .formatted(dateFormatter)
        }
        do {
            let data = try jsonEncoder.encode(encodable)
            if self.httpBody != nil {
                self.httpBody!.append(data)
            } else {
                self.httpBody = data
            }
        } catch {
            print("Error encoding object into JSON \(error)")
        }
    }

}
