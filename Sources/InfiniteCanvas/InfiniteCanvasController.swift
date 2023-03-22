import Foundation

public class InfiniteCanvasController: ObservableObject {
    @Published public private(set) var contentOffset: CGPoint = .zero
    public private(set) var scale: CGFloat = 1
    public private(set) var visibleRect: CGRect = .zero
    public var minimumMagnification: CGFloat = 0.05
    public var maximumMagnification: CGFloat = 3

    private var frameSize: CGSize = .zero
    
    private var lastUpdate: Int = .zero
    
    public init() {}
    
    public init(initialOffset: CGPoint, initialScale: CGFloat) {
        self.contentOffset = initialOffset
        self.scale = initialScale
    }
    
    public func setFrameSize(size newSize: CGSize) {
        self.frameSize = newSize
        recomputeVisibleRect(self.contentOffset.x, self.contentOffset.y)
    }
    
    public func magnify(by magnification: CGFloat, point: CGPoint) {
        let previousScale = self.scale
        let newScale = capScale(self.scale + magnification)
        
        let beforeScaleX = (point.x / previousScale) + self.contentOffset.x
        let beforeScaleY = (point.y / previousScale) + self.contentOffset.y
        
        let afterScaleX = (point.x / newScale) + self.contentOffset.x
        let afterScaleY = (point.y / newScale) + self.contentOffset.y
        
        let newX = self.contentOffset.x + (beforeScaleX - afterScaleX)
        let newY = self.contentOffset.y + (beforeScaleY - afterScaleY)


        self.scale = newScale
        recomputeVisibleRect(newX, newY)
        self.contentOffset.x = newX
        self.contentOffset.y = newY

        objectWillChange.send()
        
    }
    
    public func pan(deltaX: CGFloat, deltaY: CGFloat) {
        let nextContentOffsetX = self.contentOffset.x - deltaX
        let nextContentOffsetY = self.contentOffset.y - deltaY
        // Note: we must recompute visible rect before setting offset to ensure our position modifier recieves updates in order
        recomputeVisibleRect(nextContentOffsetX, nextContentOffsetY)

        self.contentOffset.x = nextContentOffsetX
        self.contentOffset.y = nextContentOffsetY
        objectWillChange.send()
        
    }
    
    public func fit(bounds: CGRect) {
        let nextScale = capScale(min(
            self.frameSize.width / bounds.width,
            self.frameSize.height / bounds.height
        ))
        
        let screenMidX = ((self.frameSize.width / 2) / nextScale) + self.contentOffset.x
        let screenMidY = ((self.frameSize.height / 2) / nextScale)  + self.contentOffset.y
        
        let boundsMidX = bounds.midX
        let boundsMidY = bounds.midY

        let nextContentOffsetX = self.contentOffset.x + (boundsMidX - screenMidX)
        let nextContentOffsetY = self.contentOffset.y + (boundsMidY - screenMidY)
        self.scale = nextScale
        // Note: we must recompute visible rect before setting offset to ensure our position modifier recieves updates in order
        recomputeVisibleRect(nextContentOffsetX, nextContentOffsetY)
        self.contentOffset.x = nextContentOffsetX
        self.contentOffset.y = nextContentOffsetY

        objectWillChange.send()
    }
    
    private func capScale(_ nextScale: CGFloat) -> CGFloat {
        return min(
            max(nextScale, self.minimumMagnification),
            self.maximumMagnification
        )
    }

    private func recomputeVisibleRect(_ nextContentOffsetX: CGFloat, _ nextContentOffsetY: CGFloat) {
        self.visibleRect = CGRect(
            x: nextContentOffsetX,
            y: nextContentOffsetY,
            width: self.frameSize.width / self.scale,
            height: self.frameSize.height / self.scale
        )
    }
}
