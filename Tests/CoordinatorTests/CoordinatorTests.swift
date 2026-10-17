import Testing
@testable import Coordinator

private enum TestEvent: Event, Equatable {
    case handledByChild
    case handledByParent
    case unhandled
}

@MainActor
private final class SpyCoordinator: Coordinator {
    weak var parentCoordinator: (any Coordinator)?
    var childCoordinators: [any Coordinator] = []

    let handles: Set<TestEvent>
    private(set) var received: [TestEvent] = []
    private(set) var startCount = 0

    init(handles: Set<TestEvent> = []) {
        self.handles = handles
    }

    func start() {
        startCount += 1
    }

    func handle(_ event: any Event) -> Bool {
        guard let event = event as? TestEvent else { return false }
        received.append(event)
        return handles.contains(event)
    }
}

@MainActor
struct CoordinatorTests {

    @Test func addChildSetsParentAndStartsChild() {
        let parent = SpyCoordinator()
        let child = SpyCoordinator()

        parent.addChild(child)

        #expect(child.parentCoordinator === parent)
        #expect(parent.childCoordinators.count == 1)
        #expect(child.startCount == 1)
    }

    @Test func eventHandledByChildDoesNotReachParent() {
        let parent = SpyCoordinator(handles: [.handledByParent])
        let child = SpyCoordinator(handles: [.handledByChild])
        parent.addChild(child)

        child.send(TestEvent.handledByChild)

        #expect(child.received == [.handledByChild])
        #expect(parent.received.isEmpty)
    }

    @Test func unhandledEventBubblesToParent() {
        let parent = SpyCoordinator(handles: [.handledByParent])
        let child = SpyCoordinator(handles: [.handledByChild])
        parent.addChild(child)

        child.send(TestEvent.handledByParent)

        #expect(child.received == [.handledByParent])
        #expect(parent.received == [.handledByParent])
    }

    @Test func eventNobodyHandlesStopsAtRoot() {
        let root = SpyCoordinator()
        let child = SpyCoordinator()
        root.addChild(child)

        child.send(TestEvent.unhandled)

        #expect(root.received == [.unhandled])
    }

    @Test func finishRemovesChildFromParent() {
        let parent = SpyCoordinator()
        let child = SpyCoordinator()
        parent.addChild(child)

        child.finish()

        #expect(parent.childCoordinators.isEmpty)
        #expect(child.parentCoordinator == nil)
    }

    @Test func parentIsNotRetainedByChild() {
        let child = SpyCoordinator()
        do {
            let parent = SpyCoordinator()
            parent.addChild(child)
            withExtendedLifetime(parent) {
                #expect(child.parentCoordinator != nil)
            }
        }
        #expect(child.parentCoordinator == nil)
    }
}
