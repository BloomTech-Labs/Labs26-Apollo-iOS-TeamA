// Copyright © 2020 Shawn James. All rights reserved.
// NotificationsViewController.swift

import UIKit

class NotificationsViewController: UIViewController {
    
    // MARK: - Outlets -
    @IBOutlet weak var notificationsCollectionView: UICollectionView!

    // MARK: - Properties -
    let reuseIdentifier = String.getCollectionViewCellID(.notificationsCollectionViewCell)
        
    // MARK: - View Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    
    // MARK: - Reusable
    
}

extension NotificationsViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = notificationsCollectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        cell.setDimensions(width: view.frame.width - 40, height: 80)
        return cell
    }
    
}

// MARK: - Live Previews

#if DEBUG

import SwiftUI

struct NotificationsViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        tabBarController?.selectedIndex = 1
        
        return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
    }
}

#endif
