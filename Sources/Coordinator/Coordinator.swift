//
//  Coordinator.swift
//  CoordinatorApp
//
//  Created by lucas.r.rebelato on 09/07/20.
//  Copyright © 2020 Lucas Rebelato. All rights reserved.
//

import UIKit

public enum Transition {
    case push
    case present
}

public protocol Coordinator: class {
    var childCoordinators: [Coordinator] { get set }
    var rootNavigationController: UINavigationController { get set }
    var parentCoordinator: Coordinator? { get set }

    func nextViewController(vc: UIViewController, transitionStyle: Transition)
    func nextCoordinator(coordinator: Coordinator)
    func popToRoot(animated: Bool)
    func handleEvent(with event: Event)
    func childDidFinish(_ child: Coordinator?)
}

extension Coordinator {

    public func childDidFinish(_ child: Coordinator?) {
        for (index, coordinator) in childCoordinators.enumerated() {
            if coordinator === child {
                childCoordinators.remove(at: index)
                break
            }
        }
    }

    public func handleEvent(with event: Event) { }

    public func nextCoordinator(coordinator: Coordinator) {
        coordinator.parentCoordinator = self
        childCoordinators.append(coordinator)
    }

    public func nextViewController(vc: UIViewController, transitionStyle: Transition) {
        vc.coordinator = self
        handleTransition(vc: vc, with: transitionStyle)
    }
    
    public func popToRoot(animated: Bool = true) {
        if let controllers = rootNavigationController.popToRootViewController(animated: animated) {
            controllers.forEach { childDidFinish($0.coordinator) }
        }
    }

    private func handleTransition(vc: UIViewController, with transitionStyle: Transition) {
        switch transitionStyle {
        case .push:
            rootNavigationController.pushViewController(vc, animated: true)
        case .present:
            rootNavigationController.present(vc, animated: true)
        }
    }
    
}
