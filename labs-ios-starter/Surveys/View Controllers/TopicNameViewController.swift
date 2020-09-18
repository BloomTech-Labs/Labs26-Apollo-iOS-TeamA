// Copyright © 2020 Shawn James. All rights reserved.
// TopicNameViewController.swift

import UIKit

class TopicNameViewController: UIViewController {
    
    // MARK: - Outlets -

    // MARK: - Properties -
    
    // MARK: - View Lifecycle -
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    // MARK: - Handlers
    
    // MARK: - Reusable
    
}

// MARK: - Live Previews

#if DEBUG

import SwiftUI

struct TopicNameViewControllerPreview: PreviewProvider {
    static var previews: some View {
        let storyboard = UIStoryboard(name: "Surveys", bundle: .main)
        let tabBarController = storyboard.instantiateInitialViewController() as? UITabBarController
        
        return tabBarController?.view.livePreview.edgesIgnoringSafeArea(.all)
    }
}

#endif
