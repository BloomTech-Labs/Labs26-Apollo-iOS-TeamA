// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var topicsCollectionView: UICollectionView!
    
    let reuseIdentifier = "TopicsCollectionViewCell"
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // MARK: - Sample Code -
        let topicController = TopicController()
        topicController.getAllContexts(complete: { [weak self] result in
            guard let self = self else {
                print("TopicVC is nil")
                return
            }
            switch result {
            case .success(let contexts):
                //this actually only gets a single question presently
                topicController.getQuestions(with: "\(contexts[1].id)") { result in
                    switch result {
                    case .success(let questions):
                        print(questions)
                    case .failure(let error):
                        //presents an error or logs to console (depending on if theres some action the user can take)
                        self.presentNetworkError(error: error.rawValue)
                    }
                }
            case .failure(let error):
                self.presentNetworkError(error: error.rawValue)
            }
        })
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
