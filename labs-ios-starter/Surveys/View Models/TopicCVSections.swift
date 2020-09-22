// Copyright © 2020 Shawn James. All rights reserved.
// TopicCVSections.swift

/// Sets the sections headers for the collectionView on the TopicViewController. Order sensitive. Description is label text.
enum TopicCVSections: Int, CaseIterable, CustomStringConvertible {
    case myTopics
    case joined
    
    var description: String {
        switch self {
            case .myTopics: return "My Topics"
            case .joined: return "Advanced Settings"
        }
    }
}
