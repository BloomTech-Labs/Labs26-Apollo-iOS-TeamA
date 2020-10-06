// Copyright © 2020 Lambda, Inc. All rights reserved.
// Created by Shawn James
// TopicCVSection.swift

import UIKit

/// Sets the sections headers for the collectionView on the TopicViewController. Order sensitive. Description is label text.
enum TopicCVSection: Int, CaseIterable, CustomStringConvertible {
    case leader
    case member

    var description: String {
        switch self {
        case .leader: return "Leader"
        case .member: return "Member"
        }
    }
}
