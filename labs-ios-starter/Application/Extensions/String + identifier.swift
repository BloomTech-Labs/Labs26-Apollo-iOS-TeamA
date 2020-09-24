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
    case showQuestions
    case popoverMemberList
    case topicDetailSegue
}

enum TableViewIdentifier: String {
    case profileCell
}

enum CollectionViewIdentifier: String {
    case notificationsCollectionViewCell
    case topicsCollectionViewCell
    case questionsCollectionViewCell
    case addNewQuestionCell

    case crudCollectionViewCell = "CRUDCollectionViewCell"
}

enum CollectionViewHeaderId: String {
    case topicSectionHeader
}

extension String {
    // User Defaults
    static let notificationsVCdidLoad = "notificationsVCdidLoad" // Bool: Whether or not the notifications view controller is loaded

    /// convenience method to retrieve Storyboard Identifiers
    /// - Parameter identifier: defined in `enum StoryboardIdentifier` in String + identifier.swift
    /// - Returns: the rawValue of the case with the first letter capitalized
    static func getStoryboardID(_ identifier: StoryboardIdentifier) -> String {
        // storyboard ids are capitalized
        identifier.rawValue.firstCapitalized
    }

    /// convenience method to get Segue Identifiers
    /// - Parameter identifier: defined in `enum SegueIdentifier` in String + identifier.swift
    /// - Returns: the rawValue of the case with the first letter capitalized
    static func getSegueID(_ identifier: SegueIdentifier) -> String {
        // segue ids are capitalized
        identifier.rawValue.firstCapitalized
    }

    /// convenience method to get TableView Identifiers
    /// - Parameter identifier: defined in `enum TableViewIdentifier` in String + identifier.swift
    /// - Returns: the rawValue of the case with the first letter capitalized
    static func getTableViewCellID(_ identifier: TableViewIdentifier) -> String {
        // tableView ids are capitalized
        identifier.rawValue.firstCapitalized
    }

    /// convenience method to get CollectionView Identifiers
    /// - Parameter identifier: defined in `enum CollectionViewIdentifier` in String + identifier.swift
    /// - Returns: the rawValue of the case with the first letter capitalized
    static func getCollectionViewCellID(_ identifier: CollectionViewIdentifier) -> String {
        // collectionView ids are capitalized
        identifier.rawValue.firstCapitalized
    }

    /// convenience method to get CollectionView Header Identifiers
    /// - Parameter identifier: defined in `enum CollectionViewHeaderId` in String + identifier.swift
    /// - Returns: the rawValue of the case with the first letter capitalized
    static func getCollectionViewHeaderId(_ identifier: CollectionViewHeaderId) -> String {
        // collectionView ids are capitalized
        identifier.rawValue.firstCapitalized
    }
}

extension StringProtocol {
    /// capitalize the first letter of the string without mutating the rest
    var firstCapitalized: String { prefix(1).capitalized + dropFirst() }
}
