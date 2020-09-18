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
    ///   - data: Must be encoded in .utf8
    ///
    /// - Note:  This is a mutating function
    mutating func addJSONData(_ data: Data) {

        if self.httpBody != nil {
            self.httpBody!.append(data)
        } else {
            self.httpBody = data
        }

    }

    /**
     Encode from a Swift object to JSON for transmitting to an endpoint
     - Parameters:
       - encodable: The instance to be encoded and added to the request
       - dateFormatter: (Optional) for use with JSONEncoder.dateEncodingStrategy
      error
     - Note: This is a mutating function
     */
    mutating func encode<T: Encodable>(
        from encodable: T,
        dateFormatter: DateFormatter? = nil
    ) {
        let jsonEncoder = JSONEncoder()
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
