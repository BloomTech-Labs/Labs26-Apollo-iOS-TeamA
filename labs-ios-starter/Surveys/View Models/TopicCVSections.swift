// Copyright © 2020 Shawn James. All rights reserved.
// TopicCVSections.swift

import UIKit

/// Sets the sections headers for the collectionView on the TopicViewController. Order sensitive. Description is label text.
enum TopicCVSections: Int, CaseIterable, CustomStringConvertible {
    case leader
    case member
    
    var description: String {
        switch self {
            case .leader: return "Leader"
            case .member: return "Member"
        }
    }
}

/// This links with the storyboard to configure the cells appearance and make it reusable view.
class TopicSectionHeader: UICollectionReusableView {
    @IBOutlet var sectionHeaderLabel: UILabel!
}
