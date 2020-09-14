//
//  ContextQuestion.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

/// Used to determine a Question's context. so named to avoid collision with Swift.Context
struct ContextObject: Codable {
    var id: Int
    var title: String

    enum CodingKeys: String, CodingKey {
        case id
        case title = "contextoption"
    }
}
