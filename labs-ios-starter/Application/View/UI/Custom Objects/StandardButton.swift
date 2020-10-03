// Copyright © 2020 Shawn James. All rights reserved.
// StandardButton.swift

import UIKit

/// The button styling used for most buttons
class StandardButton: UIButton {
    // MARK: - Properties

    /// used to show loading animation
    lazy var activityIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.hidesWhenStopped = true
        indicator.color = .white
        return indicator
    }()

    // MARK: - Initializers

    /// The initializer called directly by the Developer
    convenience init(withTitle text: String?, width fixedWidth: CGFloat?, height fixedHeight: CGFloat?) {
        self.init()

        if let title = text {
            setTitle(title, for: .normal)
        }

        if let width = fixedWidth {
            addConstraint(widthAnchor.constraint(equalToConstant: width))
        }

        if let height = fixedHeight {
            addConstraint(heightAnchor.constraint(equalToConstant: height))
        }

        translatesAutoresizingMaskIntoConstraints = false
    }

    /// Programmatic init
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    /// Storyboard init
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        commonInit()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        if traitCollection.userInterfaceStyle == .dark {
            layer.shadowColor = nil
            layer.shadowOpacity = 0
        } else {
            setShadow()
        }
    }

    /// Sets up the button with configuration
    private func commonInit() {
        setColors()
        setShape()
        if traitCollection.userInterfaceStyle == .light { setShadow() }
    }

    // MARK: - Configuration Methods

    /// Configure the appearance of the button's shadow
    private func setShadow() {
        layer.shadowColor = UIColor(red: 0.64, green: 0.71, blue: 0.78, alpha: 1.00).cgColor
        layer.shadowOffset = CGSize(width: 7, height: 7)
        layer.shadowRadius = 7
        layer.shadowOpacity = 0.8
    }

    /// Configures the button's color scheme
    private func setColors() {
        backgroundColor = .action
        setTitleColor(.white, for: .normal)
    }

    /// Configures the shape of the button
    private func setShape() {
        layer.cornerRadius = .cornerRadius
    }

    // MARK: - Button Animation Methods

    /// Button will spring animate to resemble a successful press
    public func springAnimate() {
        UIButton.animate(withDuration: 0.1, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: .curveEaseInOut, animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIButton.animate(withDuration: 0.2, delay: 0, usingSpringWithDamping: 0.4, initialSpringVelocity: 2, options: .curveEaseIn, animations: {
                self.transform = CGAffineTransform.identity
            }, completion: nil)
        }
    }

    /// Button will shake animate to resemble an error
    public func shakeAnimate() {
        let fromPoint = CGPoint(x: center.x - 8, y: center.y)
        let toPoint = CGPoint(x: center.x + 8, y: center.y)
        let fromValue = NSValue(cgPoint: fromPoint)
        let toValue = NSValue(cgPoint: toPoint)

        let shake = CABasicAnimation(keyPath: "position")
        shake.duration = 0.1
        shake.repeatCount = 2
        shake.autoreverses = true
        shake.fromValue = fromValue
        shake.toValue = toValue
        layer.add(shake, forKey: "position")
    }

    /// Called to visually show user that something is loading as a result of their button press
    func loadAnimate(_ shouldShow: Bool) {
        if shouldShow {
            activityIndicator.translatesAutoresizingMaskIntoConstraints = false

            addSubview(activityIndicator)
            addConstraint(//                activityIndicator.trailingAnchor.constraint(equalTo: trailingAnchor, constant: 16))
                activityIndicator.centerXAnchor.constraint(equalTo: centerXAnchor))
            addConstraint(
                activityIndicator.centerYAnchor.constraint(equalTo: centerYAnchor))

            isEnabled = false
            alpha = 0.7
            titleLabel?.alpha = 0
            activityIndicator.startAnimating()
        } else { // shouldn't show
            activityIndicator.stopAnimating()
            isEnabled = true
            alpha = 1.0
            titleLabel?.alpha = 1
        }
    }
}

// MARK: - Live Previews

#if DEBUG

    import SwiftUI

    struct StandardButtonPreview: PreviewProvider {
        static var previews: some View {
            let previewView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
            previewView.backgroundColor = .background
            let button = StandardButton(withTitle: "Sample Text", width: 280, height: 50)

            previewView.addSubview(button)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.centerXAnchor.constraint(equalTo: previewView.centerXAnchor).isActive = true
//        button.bottomAnchor.constraint(equalTo: previewView.centerYAnchor).isActive = true

            button.center(in: previewView)

            return previewView.livePreview.edgesIgnoringSafeArea(.all)
        }
    }

#endif
