// Copyright © 2020 Shawn James. All rights reserved.
// TopicDetailViewController.swift

import UIKit

class TopicDetailViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet weak var CRUDCollectionView: UICollectionView!

    // MARK: - Properties -
    let reuseIdentifier = String.collectionViewCellID(.crudCollectionViewCell)
    
    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    
    // MARK: - Reusable
    
}

extension TopicDetailViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = CRUDCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
    }
    
}

// MARK: - Live Previews

#if DEBUG

import SwiftUI

struct TopicDetailViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        
        return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
    }
}

#endif
