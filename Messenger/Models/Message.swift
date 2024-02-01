//
//  Message.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-02-01.
//

import Foundation
import MessageKit

struct Message: MessageType {
    var sender: SenderType
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
}

extension Message {
    static let mockMessages = [
        Message(sender: Sender.selfSender, messageId: "1", sentDate: Date(), kind: .text("Good time of the day!")),
        Message(sender: Sender.selfSender, messageId: "2", sentDate: Date(), kind: .text("Hi there!")),
        Message(sender: Sender.selfSender, messageId: "3", sentDate: Date(), kind: .text("Are you coming to the party?"))
    ]
}
