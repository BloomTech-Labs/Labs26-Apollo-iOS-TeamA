//
//  Member.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/8/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation


/// Standard user, leader if topic originator
struct Member: Equatable, Codable {

    var identifier: UUID?
    var token: Bearer? //if different from identifier (assign in AuthService)
    var email: String?
    var firstName: String?
    var lastName: String?


    /// - Parameters:
    ///   - identifier: defaults to new UUID, make sure to assign the correct one when decoding
    ///   rather than generating a new one
    ///   - email: optional, used for login and updating email only (defaults to nil)
    ///   - password: optional, used for login and updating password only (defaults to nil)
    ///   - firstName: optional, used for registration and updating name only (defaults to nil)
    ///   - lastName: optional, used for registration and updating name only (defaults to nil)
    init(identifier: UUID? = nil, email: String? = nil, firstName: String? = nil, lastName: String? = nil) {
        self.identifier = identifier
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
    }

    static func ==(lhs: Member, rhs: Member) -> Bool {
        lhs.identifier == rhs.identifier
    }

}
