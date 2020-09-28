// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: LoginViewController {
    // MARK: - Outlets & Properties

    @IBOutlet var topicsCollectionView: UICollectionView!

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
            guard let topic = self.topics?[selectedIndex.item] else {
                print("no topic")
                return
            }

            //TESTING, REMOVE
            let member = Member(id: "1", email: "1@1.com", firstName: "firstOne", lastName: "lastOne", avatarURL: URL(string: "http://www.url.com"))
            var members = NSSet()
            members = members.adding(member) as NSSet
            topic.members = members

            topicDetailViewController.topic = topic
        }
    }

    private func fetchTopics() {
        if !self.spinner.isAnimating {
            self.spinner.startAnimating()
        }

        topicController.fetchTopic { result in
            switch result {
            case .success(let topics):
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

    // MARK: - Navigation -



    // MARK: - Handlers

    // MARK: - Reusable
}

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
