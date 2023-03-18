import SwiftUI
import InfiniteCanvas

@MainActor
class Item: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let color: Color
    @Published var canvasX: CGFloat
    @Published var canvasY: CGFloat

    init(name: String, color: Color, canvasX: CGFloat, canvasY: CGFloat) {
        self.name = name
        self.color = color
        self.canvasX = canvasX
        self.canvasY = canvasY
    }
}

@MainActor
class AppState: ObservableObject {
    @Published var selectedItemID: UUID? = nil
    @Published var items: [Item] = []

    public init(items: [Item]) {
        self.items = items
    }
}

struct ContentView: View {
    private var controller = InfiniteCanvasController()
    @StateObject private var state: AppState = AppState(items: [
        Item(name: "Box 1", color: .red, canvasX: 0, canvasY: 0),
        Item(name: "Box 2", color: .purple, canvasX: 300, canvasY: 10),
        Item(name: "Box 3", color: .blue, canvasX: 600, canvasY: 400)
    ])

    var body: some View {
        HStack(spacing: 0) {
            ItemList(state: state)
            Canvas(state: state)
        }
        .environmentObject(controller)
    }
}

struct ItemList: View {
    @ObservedObject var state: AppState
    @EnvironmentObject private var controller: InfiniteCanvasController

    var body: some View {
        VStack {
            List(state.items, id: \.id, selection: selection) { item in
                Text(item.name)
            }
            Spacer()
            Spacer()
            HStack {
                Button("Zoom to fit") {
                    guard let selectedItem = state.items.first(where: { $0.id == state.selectedItemID }) else {
                        return
                    }
                    controller.fit(bounds: [selectedItem].bounds)
                }
                .disabled(state.selectedItemID == nil)
                Button("Fit Canvas") {
                    controller.fit(bounds: state.items.bounds)
                }
            }
            Spacer()
        }
        .frame(maxWidth: 200)
    }

    var selection: Binding<Set<UUID>> {
        Binding {
            if let selected = state.selectedItemID {
                return Set([selected])
            }
            return Set()
        } set: { newValue in
            state.selectedItemID = newValue.first
        }
    }
}

struct Canvas: View {
    @ObservedObject var state: AppState
    @EnvironmentObject private var controller: InfiniteCanvasController

    var body: some View {
        InfiniteCanvas(controller: controller) {
            ForEach(state.items, id: \.id) { item in
                CanvasItem(item: item, isSelected: item.id == state.selectedItemID)
                    .onTapGesture {
                        state.selectedItemID = item.id
                    }
            }
        }
    }
}

struct CanvasItem: View {
    @ObservedObject var item: Item
    @GestureState private var drag: CGPoint? = nil
    @EnvironmentObject private var controller: InfiniteCanvasController

    let isSelected: Bool

    var body: some View {
        Text(item.name)
            .foregroundColor(.white)
            .frame(width: 100, height: 100)
            .background(Rectangle().fill(item.color))
            .border(isSelected ? .black : .clear, width: 3)
            .canvasOffset(x: item.canvasX, y: item.canvasY)
            .canvasDraggable { event in
                item.canvasX = item.canvasX + event.deltaX
                item.canvasY = item.canvasY + event.deltaY
            }
    }
}


extension Item {
    var bounds:CGRect {
        return CGRect(x: self.canvasX, y: self.canvasY, width: 100, height: 100)
    }
}

extension Array where Element == Item {
    @MainActor
    var bounds: CGRect {
        if self.isEmpty {
            return .zero
        }
        return self.reduce(self.first!.bounds) { acc, item in
            acc.union(item.bounds)
        }
    }
}
