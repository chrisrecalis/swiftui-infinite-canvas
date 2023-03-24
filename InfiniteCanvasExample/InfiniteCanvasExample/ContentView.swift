import SwiftUI
import InfiniteCanvas

@MainActor
class Item: Identifiable, ObservableObject {
    let id = UUID()
    let name: String
    let color: Color
    @Published var position: CGPoint
    let size: CGSize
    
    
    init(name: String, color: Color, position: CGPoint, size: CGSize) {
        self.name = name
        self.color = color
        self.position = position
        self.size = size
    }
    
    var bounds: CGRect {
        CGRect(x: position.x, y: position.y, width: size.width, height: size.height)
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
    @StateObject private var state: AppState = AppState(items: (0...300).map { i in
        Item(
            name: "Box \(i)",
            color: .random,
            position: CGPoint(x: .random(in: 0...3500), y: .random(in: 0...3500)),
            size: CGSize(width: .random(in: 10...200), height: .random(in: 10...200))
        )
    })
    
    var body: some View {
        HStack(spacing: 0) {
            ItemList(state: state, controller: controller)
            Canvas(state: state, controller: controller)
        }
        .environmentObject(controller)
    }
}

struct ItemList: View {
    @ObservedObject var state: AppState
    let controller: InfiniteCanvasController
    
    var body: some View {
        VStack {
            List(state.items, id: \.id, selection: selection) { item in
                Text(item.name)
            }
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
        .border(.black.opacity(0.1), width: 1)
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
    var controller: InfiniteCanvasController
    
    var body: some View {
        InfiniteCanvas(controller: controller) {
            Color.clear
            ForEach(state.items, id: \.id) { item in
                CanvasItem(item: item, isSelected: item.id == state.selectedItemID, controller: controller)
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
    
    let isSelected: Bool
    let controller: InfiniteCanvasController
    
    
    var body: some View {
        Text(item.name)
            .foregroundColor(.white)
            .frame(width: item.size.width, height: item.size.height)
            .background(Rectangle().fill(item.color))
            .border(isSelected ? .black : .clear, width: 3)
            .canvasPosition(position: item.position, controller: controller)
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

extension Color {
    static var random: Color {
        return Color(
            red: .random(in: 0...1),
            green: .random(in: 0...1),
            blue: .random(in: 0...1)
        )
    }
}
