import SwiftUI

struct PanGestureRecognizer: ViewModifier {
    let controller: InfiniteCanvasController
    
    @GestureState private var drag: CGPoint? = nil
    
    public func body(content: Content) -> some View {
        content
            .gesture(
                DragGesture()
                    .updating($drag) { value, gestureState, transaction in
                        let deltaX = (value.location.x - (gestureState?.x ?? value.startLocation.x)) / controller.scale
                        let deltaY = (value.location.y - (gestureState?.y ?? value.startLocation.y)) / controller.scale
                        
                        controller.pan(deltaX: deltaX, deltaY: deltaY)
                        gestureState = value.location
                    }
            )
    }
}
