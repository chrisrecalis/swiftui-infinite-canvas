# InfiniteCanvas

Example
```swift
import SwiftUI
import InfiniteCanvas

struct ContentView: View {
    @StateObject private var controller = InfiniteCanvasController()
    private var items = [
        Item(canvasX: 0, canvasY: 0),
        Item(canvasX: 100, canvasY: 100),
        Item(canvasX: 200, canvasY: 200),
    ]
    
    var body: some View {
        InfiniteCanvas(controller: controller) {
            ForEach(items, id: \.id) { item in
                ItemView(item: item)
            }
        }
    }
}


struct ItemView: View {
    @ObservedObject var item: Item
    
    var body: some View {
        Circle()
            .fill(Color.red)
            .frame(width: 50, height: 50)
            .canvasOffset(x: item.canvasX, y: item.canvasY)
    }
}

class Item: Identifiable, ObservableObject {
    let id = UUID()
    @Published var canvasX: CGFloat
    @Published var canvasY: CGFloat
    
    init(canvasX: CGFloat, canvasY: CGFloat) {
        self.canvasX = canvasX
        self.canvasY = canvasY
    }
}

```
