//
//  TopicCollectionViewCell.swift
//  labs-ios-starter
//
//  Created by Kenny on 9/20/20.
//  Copyright © 2020 Lambda, Inc. All rights reserved.
//

import UIKit

protocol TopicCollectionViewCellDelegate {
    func deleteTopic(_ topic: Topic)
}

class TopicCollectionViewCell: ApolloCollectionViewCell {
    // MARK: - Outlets -
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var blurView: UIVisualEffectView!

    var delegate: TopicCollectionViewCellDelegate?
    
    var topic: Topic? {
        didSet {
            updateViews()
        }
    }

    var isEditing = false {
        didSet {
            updateViewForEditing()
        }
    }

    // MARK: - View Lifecycle -
    /// Update the views
    private func updateViews() {
        nameLabel.text = topic?.topicName
        updateViewForEditing()
        blurView.effect = traitCollection.userInterfaceStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
    }

    /// Toggle views related to entering `edit` mode
    private func updateViewForEditing() {
        blurView.isHidden = !isEditing
        deleteButton.isHidden = !isEditing
    }

    /// Handle changes to trait collection
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        blurView.effect = traitCollection.userInterfaceStyle == .dark ? UIBlurEffect(style: .dark) : UIBlurEffect(style: .light)
    }

    /// Calls methods to delete the topic locally and from server
    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let object = topic else { print("Early exit from deleteButtonPressed() -> No object"); return }
        delegate?.deleteTopic(object)
    }
}
