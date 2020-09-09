//
//  Context.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

//used to determine a Question's context
struct ContextQuestion: Codable {
    var id: UUID
    var context: [String]
}
