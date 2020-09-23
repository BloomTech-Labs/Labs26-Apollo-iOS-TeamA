// Copyright © 2020 Shawn James. All rights reserved.
// NotificationsTabItem.swift

import UIKit

/// The tab bar item that represents the NotificationsViewController's tab
class NotificationsTabItem: UITabBarItem {
    /// Storyboard init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        NotificationCenter.default.addObserver(forName: .notificationsBadgeNeedsUpdate,
                                               object: nil,
                                               queue: .main,
                                               using: updateBadge(notification:))
    }

    /// Updates the badge with the new value, removes the badge if it is not greater than 0
    private func updateBadge(notification: Notification) {
        guard let messagesCount = notification.object as? Int else { return }

        badgeValue = messagesCount > 0 ? String(messagesCount) : nil
    }
}
