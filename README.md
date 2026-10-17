# Coordinator

Coordinators for SwiftUI apps. A coordinator owns the navigation of one flow; screens only send events.

- `Coordinator`: a `@MainActor` protocol with child coordinators, `start()`, and events that bubble up to the parent until someone handles them.
- `Router`: the observable navigation state of a flow (stack path, sheet, full-screen cover).
- `RouterStack`: a `NavigationStack` driven by a `Router`.

Requires iOS 17 / macOS 14 and Swift 6. Version 1.x (UIKit, `UINavigationController`) stays available on its tags.

## Installation

```swift
.package(url: "https://github.com/rebelato/CoordinatorFramework", from: "2.0.0")
```

## Usage

Events describe what happened on a screen:

```swift
enum CheckoutEvent: Event {
    case itemSelected(Item.ID)
    case finished
}
```

A coordinator owns a router and decides what each event means:

```swift
@MainActor
@Observable
final class CheckoutCoordinator: Coordinator {
    @ObservationIgnored weak var parentCoordinator: (any Coordinator)?
    @ObservationIgnored var childCoordinators: [any Coordinator] = []

    let router = Router<CheckoutRoute>()

    func handle(_ event: any Event) -> Bool {
        switch event as? CheckoutEvent {
        case .itemSelected(let id):
            router.push(.item(id))
            return true
        case .finished:
            return false // the parent closes the flow and calls childDidFinish(self)
        case nil:
            return false
        }
    }
}
```

The view of the flow is a `RouterStack`:

```swift
RouterStack(router: coordinator.router) {
    CartView(onEvent: coordinator.send)
} destination: { route in
    switch route {
    case .item(let id): ItemView(id: id, onEvent: coordinator.send)
    }
}
```

An event that `handle(_:)` does not return `true` for is passed to the parent coordinator, so a child flow only needs to know about its own screens.
