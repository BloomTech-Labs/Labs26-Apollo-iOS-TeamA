// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import CoreData
import UIKit

class TopicViewController: LoginViewController {
    // MARK: - Outlets & Properties
    @IBOutlet var topicsCollectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    let spinner = UIActivityIndicatorView(style: .large)
    let cellReuseIdentifier = String.getCollectionViewCellID(.topicsCollectionViewCell)
    let headerReuseIdentifier = String.getCollectionViewHeaderId(.topicSectionHeader)
    let topicController = TopicController()

    private var fetchController: NSFetchedResultsController<Topic> = {
        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "timeStamp", ascending: false)]
        let mainContext = CoreDataManager.shared.mainContext
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: mainContext,
                                                                  sectionNameKeyPath: "section",
                                                                  cacheName: nil)
        return fetchedResultsController
    }()

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.center = view.center
    }

    /// from LoginViewController.swift
    override func handleLogin() {
        fetchTopics()
        configureRefreshControl()
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == .getSegueID(.topicDetailSegue) {
            guard let topicDetailViewController = segue.destination as? TopicDetailViewController else {
                print("Invalid Segue for presenting Topic Detail")
                return
            }
            guard let selectedIndex = topicsCollectionView.indexPathsForSelectedItems?.first else {
                print("couldn't get selected index")
                return
            }
            let topic = fetchController.object(at: selectedIndex)

            // TESTING, REMOVE
            let member = Member(id: "1", email: "1@1.com", firstName: "firstOne", lastName: "lastOne", avatarURL: URL(string: "http://www.url.com"))
            topic.addToMembers(member)
            topicDetailViewController.id = topic.id
            try? CoreDataManager.shared.saveContext()

        }
    }

    // MARK: - Methods
    private func fetchTopics() {
        refreshControl.beginRefreshing()
        if !spinner.isAnimating { spinner.startAnimating() }

        topicController.fetchTopicsFromServer { result in
            switch result {
            case .success:
                DispatchQueue.main.async { [self] in
                    self.refreshControl.endRefreshing()
                    self.spinner.stopAnimating()

                    do {
                        try self.fetchController.performFetch()
                    } catch {
                        print("Failure to perform fetch on fetchedResultsController: \(error)")
                    }

                    self.topicsCollectionView.reloadData()
                }
            case let .failure(error):
                self.spinner.stopAnimating()
                self.presentNetworkError(error: error.rawValue) { tryAgain in
                    if let tryAgain = tryAgain {
                        if tryAgain {
                            self.fetchTopics()
                        }
                    }
                }
            }
        }
    }

    // MARK: - Pull to Refresh
    /// Configures the collectionView's refreshControl
    private func configureRefreshControl() {
        refreshControl.addTarget(self, action: #selector(refreshControlHandler), for: .valueChanged)
        topicsCollectionView.alwaysBounceVertical = true
        topicsCollectionView.refreshControl = refreshControl
    }

    // Handler for the refresh control. Called when refreshControl value changes
    @objc private func refreshControlHandler() {
        if !topicsCollectionView.isDragging { fetchTopics() } // don't call in the middle of a drag
    }

    // Used to wait until dragging has ended to send the fetch request
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        if refreshControl.isRefreshing { fetchTopics() } // must be refreshing to call
    }
}

// MARK: - CollectionView DataSource & Delegate
extension TopicViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return fetchController.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TopicSectionHeader {
            let headerName = fetchController.sections?[indexPath.section].name ?? ""
            sectionHeader.sectionHeaderLabel.text = headerName
            return sectionHeader
        }
        fatalError("Failed to configure collectionView header. Broken method or out of range.")
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? TopicCollectionViewCell else {
            fatalError("couldn't downcast TopicCollectionViewCell 🚨CHANGE THIS BEFORE PRODUCTION🚨")
        }
        cell.topic = fetchController.object(at: indexPath)
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
    }
}
