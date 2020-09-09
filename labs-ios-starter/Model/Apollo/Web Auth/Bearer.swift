//
//  Bearer.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

//this may need to be changed once the backend is deployed
struct Bearer: Codable {
    var token: String
    var username: String
}
