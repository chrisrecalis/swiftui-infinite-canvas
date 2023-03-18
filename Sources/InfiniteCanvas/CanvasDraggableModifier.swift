import SwiftUI

public struct CanvasDraggable: ViewModifier {
    @EnvironmentObject private var controller: InfiniteCanvasController
    @GestureState private var drag: CGPoint? = nil

    @Binding var x: CGFloat
    @Binding var y: CGFloat

    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($drag) { value, gestureState, transaction in
                        let deltaX = (value.location.x - (gestureState?.x ?? value.startLocation.x)) / controller.scale
                        let deltaY = (value.location.y - (gestureState?.y ?? value.startLocation.y)) / controller.scale

                        x = x + deltaX
                        y = y + deltaY
                        gestureState = value.location
                    }
            )
    }
}


public extension View {
    func canvasDraggable(x: Binding<CGFloat>, y: Binding<CGFloat>) -> some View {
        modifier(CanvasDraggable(x: x, y: y))
    }
}
