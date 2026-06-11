import SwiftUI

struct FloatingCarousel: View {
    let items: [String]
    @Binding var selectedItem: String?
    let onSelect: (String?) -> Void
    
    let isOpen: Bool
    
    var body: some View {
        GeometryReader { geometry in
            let midX = geometry.size.width / 2
            
            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        
                        Spacer().frame(width: midX - 42)
                        
                        ForEach(items, id: \.self) { item in
                            GeometryReader { itemGeo in
                                CleanCapsuleItem(
                                    preposition: item,
                                    isSelected: selectedItem == item,
                                    action: {
                                        withAnimation {
                                            proxy.scrollTo(item, anchor: .center)
                                            selectedItem = item
                                        }
                                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                            onSelect(item)
                                        }
                                    }
                                )
                                .position(x: itemGeo.size.width / 2, y: itemGeo.size.height / 2)
                                
                                .onChange(of: itemGeo.frame(in: .global).midX) {_, newValue in
                                    guard isOpen else { return }
                                    
                                    if abs(midX - newValue) < 35 && selectedItem != item {
                                        DispatchQueue.main.async {
                                            withAnimation(.spring()) { selectedItem = item }
                                        }
                                    }
                                }
                            }
                            .frame(width: selectedItem == item ? 85 : 60, height: 140)
                            .id(item)
                        }
                        
                        GeometryReader { itemGeo in
                            CleanCapsuleItem(
                                preposition: L10n.MyProgress.Capsule.All.title,
                                isSelected: selectedItem == nil,
                                action: {
                                    withAnimation {
                                        proxy.scrollTo("ALL_BUTTON", anchor: .center)
                                        selectedItem = nil
                                    }
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
                                        onSelect(nil)
                                    }
                                }
                            )
                            .position(x: itemGeo.size.width / 2, y: itemGeo.size.height / 2)
                            
                            .onChange(of: itemGeo.frame(in: .global).midX) {_, newValue in
                                guard isOpen else { return }
                                
                                if abs(midX - newValue) < 35 && selectedItem != nil {
                                    DispatchQueue.main.async {
                                        withAnimation(.spring()) { selectedItem = nil }
                                    }
                                }
                            }
                        }
                        .frame(width: selectedItem == nil ? 85 : 60, height: 140)
                        .id("ALL_BUTTON")
                        
                        Spacer().frame(width: midX - 42)
                    }
                }
                .onAppear {
                    if let current = selectedItem {
                        proxy.scrollTo(current, anchor: .center)
                    } else if !items.isEmpty {
                        let middleIndex = items.count / 2
                        let middleItem = items[middleIndex]
                        
                        proxy.scrollTo(middleItem, anchor: .center)

                        if isOpen {
                            DispatchQueue.main.async {
                                selectedItem = middleItem
                            }
                        }
                    }
                }
            }
        }
        .frame(height: 160)
    }
}
