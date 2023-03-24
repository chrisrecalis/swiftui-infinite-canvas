import AppKit
import SwiftUI

public struct InfiniteCanvas<Content>: View where Content : View {
    private let controller: InfiniteCanvasController
    @ViewBuilder private let content: () -> Content
    
    public init(controller: InfiniteCanvasController, @ViewBuilder content: @escaping () -> Content) {
        self.controller = controller
        self.content = content
    }
    
    public var body: some View {
        InfiniteScrollViewRepresentable(controller: controller) {
            ZStack(alignment: .topLeading) {
                content()
            }
        }
        .modifier(PanGestureRecognizer(controller: controller))
    }
}
