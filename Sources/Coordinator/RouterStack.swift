//
//  RouterStack.swift
//
//
//  Created by Lucas Rebelato on 17/10/26.
//

import SwiftUI

/// A `NavigationStack` driven by a ``Router``.
///
/// Pushed routes, the sheet and the full-screen cover are all built by the
/// same `destination` closure, so every screen of a flow is declared in one place.
///
/// ```swift
/// RouterStack(router: coordinator.router) {
///     CaptureView(viewModel: coordinator.captureViewModel)
/// } destination: { route in
///     coordinator.view(for: route)
/// }
/// ```
public struct RouterStack<Route: Hashable, Root: View, Destination: View>: View {

    @Bindable private var router: Router<Route>
    private let root: Root
    private let destination: (Route) -> Destination

    public init(
        router: Router<Route>,
        @ViewBuilder root: () -> Root,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) {
        self._router = Bindable(router)
        self.root = root()
        self.destination = destination
    }

    public var body: some View {
        NavigationStack(path: $router.path) {
            root.navigationDestination(for: Route.self) { route in
                destination(route)
            }
        }
        .presentations(of: router, destination: destination)
    }
}

extension View {

    /// Shows the router's sheet and full-screen cover over this view, without a navigation stack.
    ///
    /// Use it on a root that is not a stack, such as a `TabView`.
    public func presentations<Route: Hashable, Destination: View>(
        of router: Router<Route>,
        @ViewBuilder destination: @escaping (Route) -> Destination
    ) -> some View {
        modifier(RouterPresentationModifier(router: router, destination: destination))
    }
}

/// Wraps a route so it can drive `sheet(item:)`, which keeps the content alive during the dismiss animation.
private struct IdentifiedRoute<Route: Hashable>: Identifiable {
    let route: Route
    var id: Route { route }
}

private struct RouterPresentationModifier<Route: Hashable, Destination: View>: ViewModifier {

    @Bindable var router: Router<Route>
    let destination: (Route) -> Destination

    func body(content: Content) -> some View {
        content
            .sheet(item: binding(for: \.sheet)) { item in
                destination(item.route)
            }
            #if os(iOS)
            .fullScreenCover(item: binding(for: \.fullScreenCover)) { item in
                destination(item.route)
            }
            #else
            .sheet(item: binding(for: \.fullScreenCover)) { item in
                destination(item.route)
            }
            #endif
    }

    private func binding(
        for keyPath: ReferenceWritableKeyPath<Router<Route>, Route?>
    ) -> Binding<IdentifiedRoute<Route>?> {
        Binding(
            get: { router[keyPath: keyPath].map(IdentifiedRoute.init) },
            set: { router[keyPath: keyPath] = $0?.route }
        )
    }
}
