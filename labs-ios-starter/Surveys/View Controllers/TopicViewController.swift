// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var topicsCollectionView: UICollectionView!
    
    let reuseIdentifier = String.getCollectionViewCellID(.topicsCollectionViewCell)
    let topicController = TopicController()

    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        topicController.fetchTopic { result in
            switch result {
            case .success(let topics):
                DispatchQueue.main.async {
                    print(topics)
                }
            case .failure(let error):
                self.presentNetworkError(error: error.rawValue) { (tryAgain) in
                    if let tryAgain = tryAgain {
                        if tryAgain {
//                            topicController.fetchTopic()
                        }
                    }
                }
            }
        }
    }


    // MARK: - Handlers

    // MARK: - Reusable

}

extension TopicViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = topicsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
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
