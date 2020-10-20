// Copyright © 2020 Shawn James. All rights reserved.
// NotificationsCollectionViewCell.swift

import UIKit

class NotificationsCollectionViewCell: ApolloCollectionViewCell {
    // MARK: - Outlets
    @IBOutlet var messageLabel: UILabel! {
        didSet {
            configureDismissButton()
        }
    }

    @IBOutlet var dismissButton: UIButton!

    // MARK: - Properties
    var managedObject: NewNotificationsMessage?

    // MARK: - Methods
    @IBAction func dismissButtonPressed(_ sender: UIButton) {
        guard let object = managedObject else { return }
        CoreDataManager.shared.deleteObject(object)
    }

    // TODO: Future -> stretch goal
//    @IBAction func addJoinCodeToClipboard(_ sender: UIButton) {
//        guard let object = managedObject else { return }
//        let copyText = UIPasteboard.general
//        let joinCode = object.message // Strip to only JoinCode
//        copyText.string = joinCode
//        // presentAlert() -> "Copied!"
//    }

    private func configureDismissButton() {
        dismissButton.clipsToBounds = true
        dismissButton.layer.cornerRadius = .cornerRadius
        dismissButton.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]

        let lineView = UIView(frame: CGRect(x: 0, y: 0, width: dismissButton.frame.width, height: 1.2))
        lineView.backgroundColor = .background
        dismissButton.addSubview(lineView)
    }
}
