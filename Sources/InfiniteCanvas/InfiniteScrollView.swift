import SwiftUI

struct InfiniteScrollViewRepresentable<Content: View>: NSViewRepresentable {
    let controller: InfiniteCanvasController
    @ViewBuilder let content: () -> Content
    
    func updateNSView(_ nsView: InfiniteScrollView<Content>, context: Context) {
        nsView.hostingView.rootView = content()
    }
    
    func makeNSView(context: Context) -> InfiniteScrollView<Content> {
        let scrollView = InfiniteScrollView<Content>()
        scrollView.controller = controller
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        
        let hostingView = NSHostingView(rootView: content())
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        
        scrollView.addSubview(hostingView)
        scrollView.hostingView = hostingView
        
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: hostingView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: hostingView.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: hostingView.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: hostingView.bottomAnchor),
        ])
        return scrollView
    }
}

class InfiniteScrollView<Content: View>: NSView {
    var controller: InfiniteCanvasController!
    var hostingView: NSHostingView<Content>!
    
    override var isFlipped: Bool { true }
    
    override func scrollWheel(with event: NSEvent) {
        if event.modifierFlags.contains(.command) {
            let point = self.convert(event.locationInWindow, from: nil)
            controller.magnify(by: event.scrollingDeltaY / 200, point: point)
            return
        }
        controller.pan(deltaX: event.scrollingDeltaX, deltaY: event.scrollingDeltaY)
    }
    
    override func magnify(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        controller.magnify(by: event.magnification, point: point)
    }
    
    override func setFrameSize(_ newSize: NSSize) {
        controller.setFrameSize(size: newSize)
        super.setFrameSize(newSize)
    }
}
