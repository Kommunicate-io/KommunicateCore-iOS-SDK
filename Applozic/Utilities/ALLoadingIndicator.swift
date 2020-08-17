//
//  ALActivityIndicator.swift
//  Applozic
//
//  Created by Sunil on 11/08/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

import Foundation
import UIKit

@objc public class ALLoadingIndicator: UIStackView {
    // MARK: - Properties

    var activityIndicator = UIActivityIndicatorView(style: .white)

    var loadingLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 1
        return label
    }()

    // MARK: - Initializer

    @objc public init(frame: CGRect, color: UIColor = .black) {
        super.init(frame: frame)
        set(color)
        setupView()
        isHidden = true
    }

    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Public methods

    @objc public func startLoading(loadText: String) {
        loadingLabel.text = loadText
        isHidden = false
        activityIndicator.startAnimating()
    }

    @objc public func stopLoading() {
        isHidden = true
        activityIndicator.stopAnimating()
    }

    @objc public func set(_ color: UIColor) {
        activityIndicator.color = color
        loadingLabel.textColor = color
    }

    // MARK: - Private helper methods

    private func setupView() {
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 10
        addArrangedSubview(activityIndicator)
        addArrangedSubview(loadingLabel)
    }
}

