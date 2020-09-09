//
//  UserImage.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

struct UserImage: Codable {
    var id: UUID
    var userId: Member
    var image: Data
}
