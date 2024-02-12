//
//  Array+Extensions.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-02-12.
//

import Foundation

extension Array where Element == [String: String] {
    func valueForkeyExists(key: String, value: String) -> Bool {
        self.compactMap { $0[key] }.contains(value)
    }
}
