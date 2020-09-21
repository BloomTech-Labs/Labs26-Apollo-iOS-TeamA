//
//  TopicCollectionViewCell.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/20/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

class TopicCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets -
    @IBOutlet var nameLabel: UILabel!

    var topic: Topic? {
        didSet {
            updateViews()
        }
    }

    // MARK: - View Lifecycle -
    private func updateViews() {
        self.nameLabel.text = topic?.topicName
    }
}
