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
    @StateObject private var state: AppState = AppState(items: [
        Item(name: "Box 1", color: .red, canvasX: 100, canvasY: 100),
        Item(name: "Box 2", color: .purple, canvasX: 300, canvasY: 10),
        Item(name: "Box 3", color: .blue, canvasX: 600, canvasY: 400)
    ])

    var body: some View {
        HStack(spacing: 0) {
            ItemList(state: state)
            Canvas(state: state)
        }
    }
}

struct ItemList: View {
    @ObservedObject var state: AppState
    @State private var multiSelection = Set<UUID>()

    var body: some View {
        VStack {
            List(state.items, id: \.id, selection: selection) { item in
                Text(item.name)
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

    var body: some View {
        InfiniteCanvas {
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
