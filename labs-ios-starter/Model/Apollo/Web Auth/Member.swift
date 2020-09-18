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
    // MARK: - Types -
    enum CodingKeys: String, CodingKey {
        case id, email
        case firstName = "firstname"
        case lastName = "lastname"
        case avatarURL = "avatarUrl"
    }

    // MARK: - Properties -
    var oktaID: String?
    var id: Int?
    var email: String?
    var firstName: String?
    var lastName: String?
    var avatarURL: URL?

    //holds image after downloading in UserDetailVC
    var image: UIImage?

    // MARK: - Init -
    /// - Parameters:
    ///   - oktaID: the user's current Okta Bearer Token (only used for login)
    ///   - id: defaults to new UUID, make sure to assign the correct one when decoding
    ///   rather than generating a new one
    ///   - email: optional, used for login and updating email only (defaults to nil)
    ///   - firstName: optional, used for registration and updating name only (defaults to nil)
    ///   - lastName: optional, used for registration and updating name only (defaults to nil)
    ///   - avatarURL: optional, used for displaying the user's profile image
    init(oktaID: String?, id: Int?, email: String? = nil, firstName: String? = nil, lastName: String? = nil, avatarURL: URL? = nil) {
        self.oktaID = oktaID
        self.id = id
        self.email = email
        self.firstName = firstName
        self.lastName = lastName
        self.avatarURL = avatarURL
    }
    /// Manual decoding to handle same key used for different properties
    init (from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        //if id is Int, this is a web user ID
        id = try? container.decode(Int.self, forKey: .id)
        //if id is String, this is an Okta ID
        if id == nil {
            oktaID = try? container.decode(String.self, forKey: .id)
        }

        email = try? container.decode(String.self, forKey: .email)
        firstName = try container.decode(String.self, forKey: .firstName)
        lastName = try container.decode(String.self, forKey: .lastName)
        avatarURL = try container.decode(URL.self, forKey: .avatarURL)
    }
    // MARK: - Equatable Conformance -
    static func ==(lhs: Member, rhs: Member) -> Bool {
        lhs.oktaID == rhs.oktaID
    }

}
