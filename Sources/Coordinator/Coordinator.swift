//
//  Coordinator.swift
//  CoordinatorApp
//
//  Created by lucas.r.rebelato on 09/07/20.
//  Copyright © 2020 Lucas Rebelato. All rights reserved.
//

/// Owns the navigation of one part of the app and the coordinators below it.
///
/// Coordinators form a tree. An event sent with ``send(_:)`` is offered to
/// ``handle(_:)`` first; when it returns `false`, the event moves up to the
/// parent, so a flow only handles what it knows and leaves the rest to the
/// coordinator that owns it.
///
/// Conforming types should keep `parentCoordinator` as a `weak` property to
/// avoid a retain cycle between parent and child.
@MainActor
public protocol Coordinator: AnyObject {
    var parentCoordinator: (any Coordinator)? { get set }
    var childCoordinators: [any Coordinator] { get set }

    /// Prepares the initial state of the flow. Called once, by whoever creates the coordinator.
    func start()

    /// Reacts to an event. Return `true` when the event was handled here,
    /// `false` to let it continue to the parent coordinator.
    func handle(_ event: any Event) -> Bool
}

extension Coordinator {

    public func start() {}

    public func handle(_ event: any Event) -> Bool { false }

    /// Offers the event to this coordinator and, if it is not handled, to each parent in turn.
    public func send(_ event: any Event) {
        if !handle(event) {
            parentCoordinator?.send(event)
        }
    }

    /// Attaches a child coordinator and starts it.
    public func addChild(_ child: any Coordinator) {
        child.parentCoordinator = self
        childCoordinators.append(child)
        child.start()
    }

    /// Detaches a child coordinator, usually when its flow is over.
    public func childDidFinish(_ child: any Coordinator) {
        childCoordinators.removeAll { $0 === child }
        if child.parentCoordinator === self {
            child.parentCoordinator = nil
        }
    }

    /// Tells the parent that this flow is over.
    public func finish() {
        parentCoordinator?.childDidFinish(self)
    }
}
