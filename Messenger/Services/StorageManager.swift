//
//  StorageManager.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-02-02.
//

import Foundation
import FirebaseStorage

final class StorageManager {

    typealias UploadPictureCompletion = (Result<String, Error>) -> Void

    static let shared = StorageManager()

    private let storage = Storage.storage().reference()

    private init() {}

    /// Uploads profile picture to Firebase storage and returns completion with URL string to download
    func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data) { [weak self] _, error in
            guard let self = self else { return }
            guard error == nil else {
                print("DEBUG: Failed to upload profile picture to Firebase storage")
                completion(.failure(StorageError.failedToUpload))
                return
            }

            self.storage.child("images/\(fileName)").downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("DEBUG: Failed to get download URL for profile picture from Firebase storage")
                    completion(.failure(StorageError.failedToGetDownloadUrl))
                    return
                }

                let urlString = url.absoluteString
                print("DEBUG: Download URL returned from Firebase = \(urlString)")
                completion(.success(urlString))
            }
        }
    }

}

enum StorageError: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}
