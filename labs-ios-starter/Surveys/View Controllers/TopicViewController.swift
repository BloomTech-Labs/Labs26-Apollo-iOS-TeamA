// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: LoginViewController {
    // MARK: - Outlets & Properties
    @IBOutlet var topicsCollectionView: UICollectionView!

    private let refreshControl = UIRefreshControl()
    let spinner = UIActivityIndicatorView(style: .large)
    let cellReuseIdentifier = String.getCollectionViewCellID(.topicsCollectionViewCell)
    let headerReuseIdentifier = String.getCollectionViewHeaderId(.topicSectionHeader)
    let topicController = TopicController()

    var topics: [Topic]? {
        didSet {
            DispatchQueue.main.async { [weak self] in
                guard let self = self else {
                    print("TopicViewController is nil")
                    return
                }
                self.topicsCollectionView.reloadData()
            }
        }
    }

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        spinner.startAnimating()
        view.addSubview(spinner)
        spinner.center = view.center
    }
    /// from LoginViewController.swift
    // TODO: Spinner
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
            guard let topic = topics?[selectedIndex.item] else {
                print("no topic")
                return
            }

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
        if !self.spinner.isAnimating {
            self.spinner.startAnimating()
        }

        topicController.fetchTopic { result in
            switch result {
            case let .success(topics):
                DispatchQueue.main.async {
                    self.topics = topics
                    self.spinner.stopAnimating()
                }
            case .failure(let error):
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
        return TopicCVSections.allCases.count
    }

    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if let sectionHeader = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: headerReuseIdentifier, for: indexPath) as? TopicSectionHeader {
            sectionHeader.sectionHeaderLabel.text = TopicCVSections(rawValue: indexPath.section)?.description
            return sectionHeader
        }
        fatalError("Failed to configure collectionView header. Broken method or out of range.")
    }

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = TopicCVSections(rawValue: section) else { return 0 }
        switch section {
        case .leader: return topics?.count ?? 0 // TODO: frc.items in this section.count
        case .member: return 0 // TODO: frc.items in this section.count
        }
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: cellReuseIdentifier, for: indexPath) as? TopicCollectionViewCell else {
            fatalError("couldn't downcast TopicCollectionViewCell 🚨CHANGE THIS BEFORE PRODUCTION🚨")
        }
        guard let section = TopicCVSections(rawValue: indexPath.section) else {
            fatalError("Section broken or out of range")
        }
        switch section {
        case .leader, .member:
            cell.topic = topics?[indexPath.row]
            cell.setDimensions(width: view.frame.width - 40, height: 80)
            return cell
        }
    }
}

// MARK: - Live Previews

#if DEBUG

    import SwiftUI

    struct TopicViewControllerPreview: PreviewProvider {
        static var previews: some View {
            let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
            let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController

            return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
