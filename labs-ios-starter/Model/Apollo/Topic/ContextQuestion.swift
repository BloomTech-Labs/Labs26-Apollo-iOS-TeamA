//
//  Context.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct ContextQuestion: Codable {
    var id: UUID
    var context: [String]
}
