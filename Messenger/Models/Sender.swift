//
//  Sender.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-02-01.
//

import Foundation
import MessageKit

struct Sender: SenderType {
    var senderId: String
    var displayName: String
    var photoURL: String
}

extension Sender {
    static let selfSender = Sender(senderId: "1", displayName: "John Doe", photoURL: "")
}
