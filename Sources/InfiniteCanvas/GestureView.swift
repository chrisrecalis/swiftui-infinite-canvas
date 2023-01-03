import AppKit
import SwiftUI

struct ScrollEvent {
    let deltaX: CGFloat
    let deltaY: CGFloat
}

struct MagnifyEvent {
    let magnification: CGFloat
    let point: CGPoint
}

struct PanEvent {
    let x: CGFloat
    let y: CGFloat
}

protocol ScrollViewDelegateProtocol {
    func scrollWheel(with event: ScrollEvent)
    func magnify(with event: MagnifyEvent)
    func pan(with event: PanEvent)
}

class GestureView: NSView {
    private var panBy: NSPoint = .zero

    override init(frame frameRect: NSRect) {
        super.init(frame: frameRect)
        let gesture = NSPanGestureRecognizer(target: self, action: #selector(handlePan))
        self.addGestureRecognizer(gesture)
    }

    @objc func handlePan(_ sender: NSPanGestureRecognizer) {
        if sender.state == .ended {
            panBy = .zero
            return
        }

        let translation = sender.translation(in: self)
        let delta = panBy - translation
        delegate.pan(with: PanEvent(x: -delta.x, y: -delta.y))
        
        panBy = translation
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override var isFlipped: Bool { true }


    var delegate: ScrollViewDelegateProtocol!
    override var acceptsFirstResponder: Bool { true }

    override func scrollWheel(with event: NSEvent) {
        delegate.scrollWheel(with: ScrollEvent(deltaX: event.scrollingDeltaX, deltaY: event.scrollingDeltaY))
    }

    override func magnify(with event: NSEvent) {
        let point = self.convert(event.locationInWindow, from: nil)
        let magnifyEvent = MagnifyEvent(magnification: event.magnification, point: point)
        delegate.magnify(with: magnifyEvent)
    }

    override func keyDown(with event: NSEvent) {
        if event.keyCode == 24 && event.modifierFlags.contains(.command) {
            delegate.magnify(with: MagnifyEvent(magnification: 0.4, point: frameCenter))
        } else if event.keyCode == 27 && event.modifierFlags.contains(.command) {
            delegate.magnify(with: MagnifyEvent(magnification: -0.4, point: frameCenter))
        } else {
            super.keyDown(with: event)
        }
    }

    override func mouseDown(with event: NSEvent) {
        super.mouseDown(with: event)
    }

    private var frameCenter: CGPoint {
        let size = self.frame.size
        return .init(x: size.width/2, y: size.height/2)
    }

}

struct RepresentableGestureView: NSViewRepresentable, ScrollViewDelegateProtocol {
    private var scrollAction: ((ScrollEvent) -> Void)?
    private var magnifyAction: ((MagnifyEvent) -> Void)?
    private var panAction: ((PanEvent) -> Void)?

    func makeNSView(context: Context) -> GestureView {
        let view = GestureView()
        view.delegate = self
        return view
    }

    func updateNSView(_ nsView: NSViewType, context: Context) {}

    func scrollWheel(with event: ScrollEvent) {
        if let scrollAction = scrollAction {
            scrollAction(event)
        }
    }

    func magnify(with event: MagnifyEvent) {
        if let magnifyAction = magnifyAction {
            magnifyAction(event)
        }
    }

    func pan(with event: PanEvent) {
        if let panAction = panAction {
            panAction(event)
        }
    }

    func onScroll(_ action: @escaping (ScrollEvent) -> Void) -> Self {
        var newSelf = self
        newSelf.scrollAction = action
        return newSelf
    }

    func onMagnify(_ action: @escaping (MagnifyEvent) -> Void) -> Self {
        var newSelf = self
        newSelf.magnifyAction = action
        return newSelf
    }

    func onPan(_ action: @escaping (PanEvent) -> Void) -> Self {
        var newSelf = self
        newSelf.panAction = action
        return newSelf
    }
}



private extension CGPoint {
    static func -(lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        CGPoint(x: lhs.x - rhs.x, y: lhs.y - rhs.y)
    }
}
