*Version 2.0.0*

- SwiftUI support: `Router` (observable stack path, sheet and full-screen cover) and `RouterStack`
- `Coordinator` is now `@MainActor`, with `start()`, `send(_:)`, `addChild(_:)` and `finish()`; events bubble up to the parent until one coordinator handles them
- `Event` is now `Sendable`
- Requires iOS 17 / macOS 14 and Swift 6
- Breaking: removed the UIKit API (`UINavigationController`, `nextViewController`, `UIViewController.coordinator`); use the 1.x tags for UIKit apps
- Tests for coordinators and router; CI runs `swift test` and an iOS Simulator build

*Version 1.0.0*

- Adding files for Coordinator framework
