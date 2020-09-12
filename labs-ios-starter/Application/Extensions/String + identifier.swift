//
//  String + identifier.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

enum StoryboardIdentifier: String {
    case profileDetailViewController
    case surveyTabBarController
    case profileNavigationController
}

enum SegueIdentifier: String {
    case showProfileDetail
    case showDetailProfileList
    case modalAddProfile
}

extension String {
    ///convenience method to retrieve Storyboard Identifiers
    static func getStoryboardIdentifier(identifier: StoryboardIdentifier) -> String {
        //storyboard ids are capitalized
        identifier.rawValue.capitalized
    }

    ///convenience method to get Segue Identifiers
    static func getSegueIdentifier(identifier: SegueIdentifier) -> String {
        //segue ids are capitalized
        identifier.rawValue.capitalized
    }
}

