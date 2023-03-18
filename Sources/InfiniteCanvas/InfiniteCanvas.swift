import SwiftUI

public struct InfiniteCanvas<Content: View>: View {
    var content: () -> Content

    @GestureState private var magnifyBy = 1.0
    private var controller: InfiniteCanvasController

    public init(@ViewBuilder content: @escaping () -> Content) {
        self.controller = InfiniteCanvasController()
        self.content = content
    }

    public init(controller: InfiniteCanvasController, @ViewBuilder content: @escaping () -> Content) {
        self.controller = controller
        self.content = content
    }

    public var body: some View {
        ZStack(alignment: .topLeading) {
            content()
        }
        .environmentObject(controller)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(GeometryReader { proxy in
            Color.clear
                .preference(key: SizePreferenceKey.self, value: proxy.size)
        })
        .onPreferenceChange(SizePreferenceKey.self) { newSize in
            controller.setViewSize(size: newSize)
        }
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

public class InfiniteCanvasController: ObservableObject {
    public private(set) var offsetX: CGFloat = 0
    public private(set) var offsetY: CGFloat = 0
    public private(set) var scale: CGFloat = 1
    public var minimumMagnification: CGFloat = 0.4
    public var maximumMagnification: CGFloat = 3
    private var size: CGSize = .zero

    public init() {}

    public init(initialOffsetX: CGFloat, initialOffsetY: CGFloat, initialScale: CGFloat) {
        self.offsetX = initialOffsetX
        self.offsetY = initialOffsetY
        self.scale = initialScale
    }

    public func setViewSize(size newSize: CGSize) {
        self.size = newSize
    }

    public func magnify(by magnification: CGFloat, point: CGPoint) {
        let previousScale = self.scale
        let newScale = capScale(self.scale + magnification)

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

    public func fit(bounds: CGRect) {
        let nextScale = capScale(min(
            self.size.width / bounds.width,
            self.size.height / bounds.height
        ))

        let screenMidX = ((self.size.width / 2) / nextScale) + self.offsetX
        let screenMidY = ((self.size.height / 2) / nextScale)  + self.offsetY

        let boundsMidX = bounds.midX
        let boundsMidY = bounds.midY

        self.offsetX = self.offsetX + (boundsMidX - screenMidX)
        self.offsetY = self.offsetY + (boundsMidY - screenMidY)
        self.scale = nextScale

        objectWillChange.send()
    }

    private func capScale(_ nextScale: CGFloat) -> CGFloat {
        return min(
            max(nextScale, self.minimumMagnification),
            self.maximumMagnification
        )
    }
}



struct SizePreferenceKey: PreferenceKey {
    static var defaultValue: CGSize = .zero
    static func reduce(value: inout CGSize, nextValue: () -> CGSize) {}
}
