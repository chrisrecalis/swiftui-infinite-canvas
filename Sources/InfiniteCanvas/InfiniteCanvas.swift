import SwiftUI

public struct InfiniteCanvas<Content: View>: View {
    var content: () -> Content

    @GestureState private var magnifyBy = 1.0
    @StateObject private var controller = InfiniteCanvasController()

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .bottomLeading) {
            content()
        }
        .environmentObject(controller)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(
            RepresentableGestureView()
                .onScroll({ event in
                    controller.pan(deltaX: event.deltaX, deltaY: event.deltaY)
                })
                .onMagnify({ event in
                    controller.magnify(by: event.magnification, point: event.point)
                })
                .onPan { event in
                    controller.pan(deltaX: event.x, deltaY: event.y)
                }
        )
        .clipped()
    }
}

@MainActor
public class InfiniteCanvasController: ObservableObject {
    public private(set) var offsetX: CGFloat = 0
    public private(set) var offsetY: CGFloat = 0
    public private(set) var scale: CGFloat = 1
    public var minimumMagnification: CGFloat = 0.4
    public var maximumMagnification: CGFloat = 3
    private var width: CGFloat = 0
    private var height: CGFloat = 0

    public init() {}

    public init(initialOffsetX: CGFloat, initialOffsetY: CGFloat, initialScale: CGFloat) {
        self.offsetX = initialOffsetX
        self.offsetY = initialOffsetY
        self.scale = initialScale
    }


    public func magnify(by magnification: CGFloat, point: CGPoint) {
        let previousScale = self.scale
        let newScale = min(
            max(self.scale + magnification, self.minimumMagnification),
            self.maximumMagnification
        )

        let beforeScaleX = (point.x / previousScale) + self.offsetX
        let beforeScaleY = (point.y / previousScale) + self.offsetY

        let afterScaleX = (point.x / newScale) + self.offsetX
        let afterScaleY = (point.y / newScale) + self.offsetY

        let newX = self.offsetX + (beforeScaleX - afterScaleX)
        let newY = self.offsetY + (beforeScaleY - afterScaleY)

        self.offsetX = newX
        self.offsetY = newY
        self.scale = newScale

        objectWillChange.send()
    }

    public func pan(deltaX: CGFloat, deltaY: CGFloat) {
        self.offsetX = self.offsetX - deltaX
        self.offsetY = self.offsetY - deltaY
        objectWillChange.send()
    }
}


