import SwiftUI

public struct CanvasDraggableEvent {
    public let deltaX: CGFloat
    public let deltaY: CGFloat
}


public struct CanvasDraggable: ViewModifier {
    @EnvironmentObject private var controller: InfiniteCanvasController
    @GestureState private var drag: CGPoint? = nil
    let action: ((CanvasDraggableEvent) -> Void)

    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($drag) { value, gestureState, transaction in
                        let deltaX = (value.location.x - (gestureState?.x ?? value.startLocation.x)) / controller.scale
                        let deltaY = (value.location.y - (gestureState?.y ?? value.startLocation.y)) / controller.scale

                        action(CanvasDraggableEvent(deltaX: deltaX, deltaY: deltaY))
                        gestureState = value.location
                    }
            )
    }
}


public extension View {
    func canvasDraggable(_ action: @escaping ((CanvasDraggableEvent) -> Void)) -> some View {
        modifier(CanvasDraggable(action: action))
    }
}
