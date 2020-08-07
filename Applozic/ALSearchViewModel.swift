//
//  ALSearchViewModel.swift
//  Applozic
//
//  Created by Sunil on 02/07/20.
//  Copyright © 2020 applozic Inc. All rights reserved.
//

import Foundation

@objc public class ALSearchViewModel: NSObject {
    @objc public override init() { }
    static let forCellReuseIdentifier = "ContactCell"
    var messageList = [ALMessage]()

    @objc public func numberOfSections() -> Int {
        return 1
    }

    @objc public func numberOfRowsInSection() -> Int {
        return messageList.count
    }

    @objc public func clear() {
        messageList.removeAll()
    }

    @objc public func messageAtIndexPath(indexPath: IndexPath) -> ALMessage? {
        guard indexPath.row < messageList.count && messageList.count > 1 else {
            return nil
        }
        return messageList[indexPath.row] as ALMessage
    }

    @objc public func searchMessage(with key: String,
                                    _ completion: @escaping ((_ result: Bool) -> Void)) {
        searchMessages(with: key) { messages, error in
            guard let messages = messages, messages.count > 0,  error == nil else {
                print("Error \(String(describing: error)) while searching messages")
                completion(false)
                return
            }

            // Sort
            _ = messages
                .sorted(by: {
                    Int(truncating: $0.createdAtTime) > Int(truncating: $1.createdAtTime)
                }).filter {
                    ($0.groupId != nil || $0.to != nil)
            }.map {
                self.messageList.append($0)
            }
            completion(true)
        }
    }

    func searchMessages(
        with key: String,
        _ completion: @escaping (_ message: [ALMessage]?, _ error: Any?) -> Void
    ) {
        let service = ALMessageClientService()
        let request = ALSearchRequest()
        request.searchText = key
        service.searchMessage(with: request) { messages, error in
            guard
                let messages = messages as? [ALMessage]
                else {
                    completion(nil, error)
                    return
            }
            completion(messages, error)
        }
    }

}
