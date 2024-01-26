//
//  UIView+Extensions.swift
//  Messenger
//
//  Created by Denis Efremov on 2024-01-25.
//

import UIKit

extension UIView {

    var width: CGFloat {
        self.frame.size.width
    }

    var height: CGFloat {
        self.frame.size.height
    }

    var top: CGFloat {
        self.frame.origin.y
    }

    var bottom: CGFloat {
        self.frame.origin.y + self.frame.size.height
    }

    var left: CGFloat {
        self.frame.origin.x
    }

    var right: CGFloat {
        self.frame.origin.x + self.frame.size.width
    }

}
