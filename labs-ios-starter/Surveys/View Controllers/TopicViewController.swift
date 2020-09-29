// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import CoreData
import UIKit

class TopicViewController: LoginViewController {
    // MARK: - Outlets & Properties
    @IBOutlet var topicsCollectionView: UICollectionView!

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
    }

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
            var members = NSSet()
            members = members.adding(member) as NSSet
            topic.members = members

            topicDetailViewController.topic = topic
        }
    }

    private func fetchTopics() {
        if !spinner.isAnimating { spinner.startAnimating() }

        topicController.fetchTopicsFromServer { result in
            switch result {
            case .success:
                DispatchQueue.main.async { [self] in
                    self.spinner.stopAnimating()

                    do {
                        try self.fetchController.performFetch()
                    } catch {
                        print("Failure to perform fetch on fetchedResultsController: \(error)")
                    }

                    self.topicsCollectionView.reloadData()
                }
            case let .failure(error):
                DispatchQueue.main.async {
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
    }

    // MARK: - Navigation -

    // MARK: - Handlers

    // MARK: - Reusable
}

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
