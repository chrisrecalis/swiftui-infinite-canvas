import SwiftUI

public struct CanvasOffset: ViewModifier {
    @EnvironmentObject private var controller: InfiniteCanvasController

    let x: CGFloat
    let y: CGFloat

    public func body(content: Content) -> some View {
        content
            .offset(x: x - controller.offsetX, y: y - controller.offsetY)
            .scaleEffect(controller.scale, anchor: .topLeading)
    }
}

public extension View {
    func canvasOffset(x: CGFloat, y: CGFloat) -> some View {
        modifier(CanvasOffset(x: x, y: y))
    }
}
