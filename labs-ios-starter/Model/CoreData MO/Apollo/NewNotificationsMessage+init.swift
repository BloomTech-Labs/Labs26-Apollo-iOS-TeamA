// Copyright © 2020 Shawn James. All rights reserved.
// NewNotificationsMessage+init.swift

import CoreData

extension NewNotificationsMessage {
    convenience init(_ message: String) {
        self.init(context: CoreDataManager.shared.mainContext)
        self.message = message
        unread = true
        timestamp = Date()
    }

    /// Cleans up the call for quickly creating new notifications messages
    func newNotificationsMessage(_ message: String) {
        _ = NewNotificationsMessage(message)
        performSave()
    }

    private func performSave() {
        try? CoreDataManager.shared.saveContext()
    }
}
