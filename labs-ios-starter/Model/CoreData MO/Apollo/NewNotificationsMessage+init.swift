// Copyright © 2020 Shawn James. All rights reserved.
// NewNotificationsMessage+init.swift

import CoreData

extension NewNotificationsMessage {
    convenience init(_ message: String) {
        // Init values
        self.init(context: CoreDataManager.shared.mainContext)
        self.message = message
        unread = true // in the future, there could be support to have read/ unread messages, rather than just exist/ delete
        timestamp = Date()

        try? CoreDataManager.shared.saveContext() // Save the new notifications message

        if !UserDefaults.standard.bool(forKey: .notificationsVCdidLoad) { // check to see if VC has loaded
            NotificationCenter.default.post(Notification(name: .notificationsBadgeNeedsUpdate)) // update manually if needed
        }
    }
}
