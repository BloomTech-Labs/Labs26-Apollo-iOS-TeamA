// Copyright © 2020 Shawn James. All rights reserved.
// UIImageView+ImageDownloader.swift

import UIKit

extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        contentMode = mode

        guard let request = NetworkService.shared.createRequest(url: url, method: .get) else {
            print("Failed to create request, check URL")
            return
        }

        NetworkService.shared.loadData(using: request) { result in
            switch result {
            case let .success(data):
                guard let image = UIImage(data: data) else {
                    print("data wasn't an image")
                    return
                }
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else {
                        print("imageView was nil when image was being assigned")
                        return
                    }
                    self.image = image
                }
            case let .failure(error):
                print("Error downloading image: \(error)")
            }
        }
    }

    // Helper method
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        guard let url = URL(string: link) else {
            print("couldn't create URL from \(link) when downloading image")
            return
        }
        downloaded(from: url, contentMode: mode)
    }
}
