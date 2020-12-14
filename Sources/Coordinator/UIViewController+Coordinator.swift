//
//  UIViewController+Coordinator.swift
//  CoordinatorApp
//
//  Created by lucas.r.rebelato on 09/07/20.
//  Copyright © 2020 Lucas Rebelato. All rights reserved.
//

import UIKit

extension UIViewController {
    public var coordinator: Coordinator? {
        get { return AssociatedObject.get(base: self, key: &CoordiantorKeys.responderKey) }
        set { AssociatedObject.set(base: self, key: &CoordiantorKeys.responderKey, value: newValue) }
    }
}

private struct CoordiantorKeys {
    static var responderKey: UInt8 = 1
}

private struct AssociatedObject {

    static func get<T: Any>(base: Any, key: UnsafePointer<UInt8>, initializer: () -> T) -> T {
        if let value = objc_getAssociatedObject(base, key) as? T {
            return value
        }

        let value = initializer()
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
        return value
    }

    static func get<T: Any>(base: Any, key: UnsafePointer<UInt8>) -> T? {
        return objc_getAssociatedObject(base, key) as? T
    }

    static func set<T: Any>(base: Any, key: UnsafePointer<UInt8>, value: T) {
        objc_setAssociatedObject(base, key, value, .OBJC_ASSOCIATION_RETAIN)
    }
}
