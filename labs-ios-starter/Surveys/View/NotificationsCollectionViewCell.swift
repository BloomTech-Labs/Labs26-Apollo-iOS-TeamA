// Copyright © 2020 Shawn James. All rights reserved.
// NotificationsCollectionViewCell.swift

import UIKit

class NotificationsCollectionViewCell: UICollectionViewCell {
    // MARK: - Outlets

    @IBOutlet var messageLabel: UILabel! {
        didSet {
            updateViews()
        }
    }

    @IBOutlet var deleteButtonBackground: UIVisualEffectView!
    @IBOutlet var deleteButton: UIButton!

    // MARK: - Properties

    var isEditing = false {
        didSet {
            updateViews()
        }
    }
    
    var managedObject: NewNotificationsMessage?

    // MARK: - Methods

    @IBAction func deleteButtonPressed(_ sender: UIButton) {
        guard let object = managedObject else { return }
        CoreDataManager.shared.deleteObject(object)
    }

    private func updateViews() {
        deleteButtonBackground.isHidden = !isEditing
        deleteButton.isHidden = !isEditing
    }
}
