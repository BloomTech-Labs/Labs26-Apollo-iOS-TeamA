//
//  String + identifier.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/12/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import Foundation

enum StoryboardIdentifier: String {
    case profileDetailViewController = "ProfileDetailViewController"
    case surveyTabBarController = "SurveyTabBarController"
    case profileNavigationController = "ProfileNavigationController"
}
///convenience method to retrieve storyboardIdentifiers
func getStoryboardIdentifier(identifier: StoryboardIdentifier) -> String {
    identifier.rawValue
}

enum SegueIdentifier: String {
    case sample
}
///convenience method to get Segue Identifiers
func getSegueIdentifier(identifier: SegueIdentifier) -> String {
    identifier.rawValue
}
