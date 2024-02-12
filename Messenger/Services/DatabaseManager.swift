//
//  DatabaseManager.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-28.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {

    static let shared = DatabaseManager()
    private let database = Database.database().reference()

    private init() {}

    static func safeEmail(with emailAddress: String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

}

// MARK: - Account Management

extension DatabaseManager {

    /// Checks if the email address is already in Firebase Realtime Database.
    /// Returns TRUE if the email does NOT exist
    public func userExists(with email: String, completion: @escaping (Bool) -> Void) {

        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")

        database.child(safeEmail).observeSingleEvent(of: .value) { snapshot in
            guard let _ = snapshot.value as? String else {
                completion(false)
                return
            }

            completion(true)
        }
    }

    /// Insert a new user to Firebase Realtime Database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "firstName": user.firstName,
            "lastName": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("DEBUG: Failed to insert user to Firebase database")
                completion(false)
                return
            }

            self.database.child("users").observeSingleEvent(of: .value) { snapshot, _ in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newElement = [
                        "name": user.firstName + " " + user.lastName,
                        "email": user.safeEmail
                    ]
                    if !usersCollection.valueForkeyExists(key: "email", value: user.safeEmail) {
                        usersCollection.append(newElement)
                    }

                    self.database.child("users").setValue(usersCollection) { error, _ in
                        guard error == nil else {
                            // TODO: - Add Error Handling
                            print("DEBUG: Failed to set usersCollection for users")
                            completion(false)
                            return
                        }
                        completion(true)
                    }

                } else {
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection) { error, _ in
                        guard error == nil else {
                            // TODO: - Add Error Handling
                            print("DEBUG: Failed to set newCollection for users")
                            completion(false)
                            return
                        }
                        completion(true)
                    }
                }
            }
        })
    }

    func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value) { snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetchUsers))
                return
            }

            completion(.success(value))
        }
    }
}

enum DatabaseError: Error {
    case failedToFetchUsers
}
