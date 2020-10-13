// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import CoreData
import UIKit

class TopicViewController: LoginViewController, NSFetchedResultsControllerDelegate {
    // MARK: - Outlets & Properties
    @IBOutlet var topicsCollectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    let spinner = UIActivityIndicatorView(style: .large)
    let cellReuseIdentifier = String.getCollectionViewCellID(.topicsCollectionViewCell)
    let headerReuseIdentifier = String.getCollectionViewHeaderId(.topicSectionHeader)
    let topicController = TopicController()

    lazy var fetchedResultsController: NSFetchedResultsController<Topic> = {
        let fetchRequest: NSFetchRequest<Topic> = Topic.fetchRequest()

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "timeStamp",
                             ascending: false)
        ]

        if let member = profileController.authenticatedUserProfile,
            let userId = member.id {
            fetchRequest.predicate = NSPredicate(format: "leaderId == %@ OR %@ IN members", userId, member)
        }

        let context = CoreDataManager.shared.mainContext
        let frc = NSFetchedResultsController(fetchRequest: fetchRequest,
                                             managedObjectContext: context,
                                             sectionNameKeyPath: "section",
                                             cacheName: nil)
        frc.delegate = self
        do {
            try frc.performFetch()
        } catch let frcError {
            NSLog(
                """
                Error fetching data from frc: \(#file), \(#function), \(#line) -
                \(frcError)
                """)
        }
        return frc
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

            guard let topic = fetchedResultsController.fetchedObjects?[selectedIndex.row] else { return }

            // TESTING, REMOVE
            let member = Member(id: "1", email: "1@1.com", firstName: "firstOne", lastName: "lastOne", avatarURL: URL(string: "http://www.url.com"))
            topic.addToMembers(member)
            topicDetailViewController.id = topic.id
            try? CoreDataManager.shared.saveContext()
        }
    }

    // MARK: - Methods
    private func fetchTopics() {
        if !refreshControl.isRefreshing { refreshControl.beginRefreshing() }
        if !spinner.isAnimating { spinner.startAnimating() }

        topicController.fetchTopicsFromServer { result in
            switch result {
            case .success:
//                    let fetchController = FetchController()
//                    // map IDs
//                    let serverTopicIDs = topics.map { Int($0.id ?? 0) }
//                    // fetch topics from CoreData
//                    let memberTopics = fetchController.fetchMemberTopics(with: serverTopicIDs)!
//                    let leaderTopics = fetchController.fetchLeaderTopics(with: serverTopicIDs)!
//                    // init topics and append arrays
//                    self.topics = []
//                    self.topics?.append(contentsOf: memberTopics)
//                    self.topics?.append(contentsOf: leaderTopics)

                DispatchQueue.main.async { [self] in
                    if self.refreshControl.isRefreshing {
                        self.refreshControl.endRefreshing()
                    }
                    do {
                        try fetchedResultsController.performFetch()
                        self.spinner.stopAnimating()
                        topicsCollectionView.reloadData()
                    } catch {
                        print("Error fetching Topics from CoreData")
                    }
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
        return fetchedResultsController.sections?.count ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
//        guard
//            let section = TopicCVSection(rawValue: section), // >< "Missing section",
//            let leaderCount = topics?.filter({ $0.section == "Leader" }).count ?? 0, // >< "failed to filter leader topics
//            let memberCount = topics?.filter({ $0.section == "Member" }).count ?? 0 // >< "failed to filter member topics
//        else {
//            print("Early exit from numberOfItemsInSection")
//            return 1
//        }
//        switch section {
//        case .leader: return leaderCount
//        case .member: return memberCount
//        }
        fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        guard let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind,
                                                                                  withReuseIdentifier: headerReuseIdentifier,
                                                                                  for: indexPath) as? TopicSectionHeader
        else {
            fatalError("Failed to configure collectionView header. Broken method or out of range.")
        }
        let section = indexPath.section
        sectionHeader.sectionHeaderLabel.text = TopicCVSection(rawValue: section)!.description

        return sectionHeader
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard
            let section = TopicCVSection(rawValue: indexPath.section) >< "Section broken or out of range",
            let fetchedResults = fetchedResultsController.fetchedObjects >< "no fetched objects",
            let topic = fetchedResults[indexPath.row] >< "Missing topic",
            let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier,
                                                                for: indexPath) as? TopicCollectionViewCell >< "Bad cell"
        else {
            fatalError("couldn't configure TopicCollectionViewCell 🚨CHANGE THIS BEFORE PRODUCTION🚨")
        }
        switch section { // implementation is same for now but may be different later
        case .leader:
            cell.topic = topic
            cell.setDimensions(width: view.frame.width - 40, height: 80) // size in delegate methods to remove warnings?
            return cell
        case .member:
            cell.topic = topic
            cell.setDimensions(width: view.frame.width - 40, height: 80) // size in delegate methods to remove warnings?
            return cell
        }
    }
}
