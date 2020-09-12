// Copyright © 2020 Shawn James. All rights reserved.
// UIImageView+ImageDownloader.swift

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode
        
        let networkService = NetworkService() // TODO: Use the singleton once it's available
        guard let request = networkService.createRequest(url: url, method: .get) else {
            print("Failed to create request, check URL")
            return
        }
        
        networkService.dataLoader.loadData(using: request) { data, response, error in
            guard
                let httpURLResponse = response, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() { [weak self] in
                self?.image = image
            }
        }
    }
    // Helper method
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}
