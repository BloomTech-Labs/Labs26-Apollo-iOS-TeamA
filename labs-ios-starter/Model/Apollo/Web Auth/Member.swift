//
//  Member.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit


/// Standard user, leader if topic originator
struct Member: Equatable, Codable {

    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "firstname"
        case lastName = "lastname"
        case avatarURL = "avatarUrl"
    }

    var id: String?
    var email: String?
    var firstName: String?
    var lastName: String?
    var avatarURL: URL?

    //holds image after downloading in UserDetailVC
    var image: UIImage?

    /// - Parameters:
    ///   - identifier: defaults to new UUID, make sure to assign the correct one when decoding
    ///   rather than generating a new one
    ///   - email: optional, used for login and updating email only (defaults to nil)
    ///   - password: optional, used for login and updating password only (defaults to nil)
    ///   - firstName: optional, used for registration and updating name only (defaults to nil)
    ///   - lastName: optional, used for registration and updating name only (defaults to nil)
    init(id: String? = nil, email: String? = nil, firstName: String? = nil, lastName: String? = nil, avatarURL: URL? = nil) {
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
    }

    static func ==(lhs: Member, rhs: Member) -> Bool {
        lhs.id == rhs.id
    }

}
