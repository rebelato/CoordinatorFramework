//
//  Router.swift
//
//
//  Created by Lucas Rebelato on 17/10/26.
//

import Observation

/// How a route is shown when it is not pushed onto the stack.
public enum PresentationStyle: Sendable {
    case sheet
    case fullScreenCover
}

/// The navigation state of one flow: the pushed stack plus whatever is presented over it.
///
/// A coordinator owns a router and changes it in response to events;
/// ``RouterStack`` turns that state into a `NavigationStack`, a sheet and a
/// full-screen cover.
@MainActor
@Observable
public final class Router<Route: Hashable> {

    /// Routes pushed onto the stack, in order. The root view is not part of the path.
    public var path: [Route]

    /// The route presented as a sheet, if any.
    public var sheet: Route?

    /// The route presented as a full-screen cover, if any. On macOS it is shown as a sheet.
    public var fullScreenCover: Route?

    public init(path: [Route] = []) {
        self.path = path
    }

    public func push(_ route: Route) {
        path.append(route)
    }

    public func pop() {
        guard !path.isEmpty else { return }
        path.removeLast()
    }

    /// Pops everything above the last occurrence of `route`. Does nothing if the route is not in the path.
    public func pop(to route: Route) {
        guard let index = path.lastIndex(of: route) else { return }
        path.removeSubrange(path.index(after: index)...)
    }

    public func popToRoot() {
        path.removeAll()
    }

    public func present(_ route: Route, style: PresentationStyle = .sheet) {
        switch style {
        case .sheet:
            sheet = route
        case .fullScreenCover:
            fullScreenCover = route
        }
    }

    /// Dismisses the topmost presentation: the full-screen cover first, then the sheet.
    public func dismiss() {
        if fullScreenCover != nil {
            fullScreenCover = nil
        } else {
            sheet = nil
        }
    }
}
