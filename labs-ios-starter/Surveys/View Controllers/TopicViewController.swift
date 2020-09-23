// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var topicsCollectionView: UICollectionView!
    
    let reuseIdentifier = String.getCollectionViewCellID(.topicsCollectionViewCell)
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
        topicController.fetchTopic { result in
            switch result {
            case .success(let topics):
                DispatchQueue.main.async {
                    self.topics = topics
                }
            case .failure(let error):
                self.presentNetworkError(error: error.rawValue) { (tryAgain) in
                    if let tryAgain = tryAgain {
                        if tryAgain {
                            // TODO:
//                            topicController.fetchTopic()
                        }
                    }
                }
            }
        }
//        // FIXME: - Load the NotificationsViewController in a better way
//        tabBarController?.selectedIndex = 1
//        DispatchQueue.main.async {
//            self.tabBarController?.selectedIndex = 0
//        }
        NotificationsViewController.shared.viewDidLoad()
    }


    // MARK: - Handlers

    // MARK: - Reusable

}

extension TopicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        //TODO: Topics I'm a leader of vs topics I'm a member of (2 sections, or dynamic)
        topics?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? TopicCollectionViewCell else {
            fatalError("couldn't downcast TopicCollectionViewCell 🚨CHANGE THIS BEFORE PRODUCTION🚨")
        }

        cell.topic = self.topics?[indexPath.row]
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
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
