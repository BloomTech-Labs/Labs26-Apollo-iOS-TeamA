//
//  ContextQuestion.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

/// Used to determine a Question's context. so named to avoid collision with Swift.Context
struct ContextQuestion: Codable {
    var id: UUID
    var context: [String]
}
