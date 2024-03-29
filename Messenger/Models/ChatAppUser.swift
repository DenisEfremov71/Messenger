//
//  ChatAppUser.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-28.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String

    var safeEmail:String {
        emailAddress.replacingOccurrences(of: ".", with: "-").replacingOccurrences(of: "@", with: "-")
    }

    var profilePictureFilename: String {
        safeEmail + "_profile_picture.png"
    }
}
