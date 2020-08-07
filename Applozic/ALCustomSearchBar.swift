//
//  ALCustomSearchBar.swift
//  Applozic
//
//  Created by apple on 16/07/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

import Foundation
import UIKit

@objc public class ALCustomSearchBar: UIView {
    @objc public let searchBar: UISearchBar

    @objc public init(searchBar: UISearchBar) {
        self.searchBar = searchBar
        super.init(frame: CGRect(x: 0, y: 0, width: searchBar.frame.width, height: 44))
        backgroundColor = .clear
        
        self.searchBar.barTintColor = ALApplozicSettings.getColorForNavigation()
        for view in searchBar.subviews[0].subviews {
            if let cancelButton = view as? UIButton {
                cancelButton.setTitleColor(.gray, for: .normal)
            }
        }
        addSubview(searchBar)
    }

    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        searchBar.frame = bounds
    }

    @objc public func show(_ show: Bool) {
        alpha = show ? 1 : 0
        searchBar.alpha = show ? 1 : 0
    }

    @discardableResult
    @objc public override func becomeFirstResponder() -> Bool {
        searchBar.becomeFirstResponder()
        return super.becomeFirstResponder()
    }

    @discardableResult
    @objc public override func resignFirstResponder() -> Bool {
        searchBar.resignFirstResponder()
        return super.resignFirstResponder()
    }
}
