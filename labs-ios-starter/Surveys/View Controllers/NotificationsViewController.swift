// Copyright © 2020 Shawn James. All rights reserved.
// NotificationsViewController.swift

import CoreData
import UIKit

class NotificationsViewController: UIViewController {
    // MARK: - Outlets -

    @IBOutlet var editButton: UIBarButtonItem!
    @IBOutlet var notificationsCollectionView: UICollectionView!

    // MARK: - Properties -

    var blockOperations = [BlockOperation]()
    let reuseIdentifier = String.getCollectionViewCellID(.notificationsCollectionViewCell)

    private lazy var fetchedResultsController: NSFetchedResultsController<NewNotificationsMessage> = {
        let fetchRequest: NSFetchRequest<NewNotificationsMessage> = NewNotificationsMessage.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "unread = %d", true) // unread only
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timestamp", ascending: false)] // newest first
        let context = CoreDataManager.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: context,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)
        fetchedResultsController.delegate = self
        do {
            try fetchedResultsController.performFetch()
        } catch {
            print("Error Fetching -> IncompleteTasksTableView in fetchedResultsController: \(error)")
        }
        return fetchedResultsController
    }()

    // MARK: - View Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        UserDefaults.standard.set(true, forKey: .notificationsVCdidLoad)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateNotificationsBadge()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateNotificationsBadge),
                                               name: .notificationsBadgeNeedsUpdate,
                                               object: nil)

        navigationItem.rightBarButtonItem = editButtonItem
    }

    deinit {
        // Cancel all block operations when VC deallocates
        for operation: BlockOperation in blockOperations {
            operation.cancel()
        }
        blockOperations.removeAll(keepingCapacity: false)

        NotificationCenter.default.removeObserver(self)

        UserDefaults.standard.set(false, forKey: .notificationsVCdidLoad)
    }

    // MARK: - Methods

    @objc func updateNotificationsBadge() {
        let messageCount = fetchedResultsController.fetchedObjects?.count ?? 0
        NotificationCenter.default.post(name: .updateNotificationsBadge, object: messageCount)
    }
}

extension NotificationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResultsController.fetchedObjects?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = notificationsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? NotificationsCollectionViewCell else {
            fatalError("Failed to dequeue reusable cell for notificationsCollectionView")
        }

        cell.setDimensions(width: view.frame.width - 40, height: 80)
        let managedObject = fetchedResultsController.fetchedObjects?[indexPath.row]
        cell.messageLabel.text = managedObject?.message
        cell.managedObject = managedObject
        return cell
    }

    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)

        if let indexPaths = notificationsCollectionView?.indexPathsForVisibleItems {
            for indexPath in indexPaths {
                if let cell = notificationsCollectionView.cellForItem(at: indexPath) as? NotificationsCollectionViewCell {
                    cell.isEditing = editing
                }
            }
        }
    }
}

// MARK: - Fetched Results Controller Delegate Methods

extension NotificationsViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        blockOperations.removeAll(keepingCapacity: false)
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Object: \(String(describing: newIndexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.insertItems(at: [newIndexPath!])
                    }
                })
            )
        } else if type == NSFetchedResultsChangeType.update {
            print("Update Object: \(String(describing: indexPath))")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.reloadItems(at: [indexPath!])
                    }
                })
            )
        } else if type == NSFetchedResultsChangeType.move {
            print("Move Object: \(String(describing: indexPath))")

            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.moveItem(at: indexPath!, to: newIndexPath!)
                    }
                })
            )
        } else if type == NSFetchedResultsChangeType.delete {
            print("Delete Object: \(String(describing: indexPath))")

            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.deleteItems(at: [indexPath!])
                    }
                })
            )
        }
    }

    func controller(controller: NSFetchedResultsController<NSFetchRequestResult>, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        if type == NSFetchedResultsChangeType.insert {
            print("Insert Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.insertSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        } else if type == NSFetchedResultsChangeType.update {
            print("Update Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.reloadSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        } else if type == NSFetchedResultsChangeType.delete {
            print("Delete Section: \(sectionIndex)")
            blockOperations.append(
                BlockOperation(block: { [weak self] in
                    if let self = self {
                        self.notificationsCollectionView?.deleteSections(NSIndexSet(index: sectionIndex) as IndexSet)
                    }
                })
            )
        }
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        notificationsCollectionView?.performBatchUpdates({ () -> Void in
            for operation: BlockOperation in self.blockOperations {
                operation.start()
            }
        }, completion: { (_) -> Void in
            self.blockOperations.removeAll(keepingCapacity: false)

            self.updateNotificationsBadge()
        })
    }
}

// MARK: - Live Previews

#if DEBUG

    import SwiftUI

    struct NotificationsViewControllerPreview: PreviewProvider {
        static var previews: some View {
            let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
            let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
            tabBarController?.selectedIndex = 1

            return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
