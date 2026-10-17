import Testing
@testable import Coordinator

private enum Route: Hashable {
    case list
    case detail(Int)
    case settings
}

@MainActor
struct RouterTests {

    @Test func startsAtRootWithNothingPresented() {
        let router = Router<Route>()

        #expect(router.path.isEmpty)
        #expect(router.sheet == nil)
        #expect(router.fullScreenCover == nil)
    }

    @Test func pushAndPop() {
        let router = Router<Route>()

        router.push(.list)
        router.push(.detail(1))
        #expect(router.path == [.list, .detail(1)])

        router.pop()
        #expect(router.path == [.list])
    }

    @Test func popOnEmptyPathDoesNothing() {
        let router = Router<Route>()

        router.pop()

        #expect(router.path.isEmpty)
    }

    @Test func popToRouteKeepsThatRoute() {
        let router = Router<Route>(path: [.list, .detail(1), .detail(2), .settings])

        router.pop(to: .detail(1))

        #expect(router.path == [.list, .detail(1)])
    }

    @Test func popToMissingRouteDoesNothing() {
        let router = Router<Route>(path: [.list, .detail(1)])

        router.pop(to: .settings)

        #expect(router.path == [.list, .detail(1)])
    }

    @Test func popToRootClearsPath() {
        let router = Router<Route>(path: [.list, .detail(1)])

        router.popToRoot()

        #expect(router.path.isEmpty)
    }

    @Test func presentUsesTheRequestedStyle() {
        let router = Router<Route>()

        router.present(.settings)
        router.present(.list, style: .fullScreenCover)

        #expect(router.sheet == .settings)
        #expect(router.fullScreenCover == .list)
    }

    @Test func dismissClosesFullScreenCoverBeforeSheet() {
        let router = Router<Route>()
        router.present(.settings)
        router.present(.list, style: .fullScreenCover)

        router.dismiss()
        #expect(router.fullScreenCover == nil)
        #expect(router.sheet == .settings)

        router.dismiss()
        #expect(router.sheet == nil)
    }
}
