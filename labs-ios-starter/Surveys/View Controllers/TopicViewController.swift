// Copyright © 2020 Shawn James. All rights reserved.
// TopicViewController.swift

import UIKit

class TopicViewController: UIViewController {
    
    // MARK: - Outlets & Properties
    @IBOutlet weak var topicsCollectionView: UICollectionView!
    @IBOutlet weak var addNewTopicButton: CircularButton!
    
    let reuseIdentifier = "TopicsCollectionViewCell"
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    /// Segues to new controller and runs an animation on the button
    @IBAction func addNewTopicButtonPressed(_ sender: CircularButton) {
        addNewTopicButton.springAnimate()
    }
    
    
    
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
