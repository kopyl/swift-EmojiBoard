import SwiftUI
import SwiftData
import EmojiPalette

let spacing: CGFloat = 0
let buttonSize: CGFloat = 50
let emojiList = ["👍️️️️️️", "❤️", "😍", "🔥", "✅", "❌", "🤔", "🤡", "😄", "🤮", "🙏", "🚫", "😂", "😭", "🤬", "😀", "🍌", "🥰", "🚩", "👇", "☝️"]
let animationDuration = 0.1

func vibrate() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.prepare()
    generator.impactOccurred()
}

extension Binding {
    @MainActor
    func onChange(_ handler: @escaping (Value) -> Void) -> Binding<Value> {
        Binding(
            get: { self.wrappedValue },
            set: { newValue in
                self.wrappedValue = newValue
                handler(newValue)
            }
        )
    }
}

@available(iOS 17.0, *)
struct ContentView: View {
    
    @State private var isInRemovingState = false
    
    @State var showPopover: Bool = false
    @State var emoji: String = ""
    
    @State private var isAlertPresented = false
    
    @Environment(\.modelContext) private var context
    @Query private var emojiLocalStorageItemsList: Array<DataItem>

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: buttonSize), spacing: spacing)
    ]

    @State private var pressedItem: String? = nil
    @State private var isHeaderEmojiVisible: Bool = false
    @State private var pressedItemTopDisplay: String = "❤️"

    @State private var pressedButtonColor: Color = Color("emoji-pressed-bg-color")

    @State private var dispatchWorkItemArray: Array<DispatchWorkItem> = []
    
    @State private var CurrentlyPressedTopDisplayScale: CGFloat = 0
    
    func getPresetAndUserEmojis() -> [String] {
        var deduplicatedItems: Array<String> = []

        let sortedLocalStorageItems = emojiLocalStorageItemsList
            .sorted(by: { $0.timeStampCreated < $1.timeStampCreated })
            .map { $0.emojiValue }
        
        for sortedLocalStorageItem in sortedLocalStorageItems {
            if !deduplicatedItems.contains(sortedLocalStorageItem) {
                deduplicatedItems.append(sortedLocalStorageItem)
            }
        }

        return emojiList + deduplicatedItems
    }
    
    func addItem(to emojiValue: String) {
        let allEmojisCurrentlyAccessibleToUser = getPresetAndUserEmojis()
        if allEmojisCurrentlyAccessibleToUser.contains(emojiValue) {
            showPopover = false
            return
        }
        let item = DataItem(emojiValue: emojiValue)
        context.insert(item)
        showPopover = false
    }
    
    func isItemDeleteable(_ item: String) -> Bool {
        let adedEmojis = emojiLocalStorageItemsList.map{ $0.emojiValue }
        if adedEmojis.contains(item) {
            return true
        }
        return false
    }
    
    func thereAreItemsLeftToBeDeleted() -> Bool {
        return getPresetAndUserEmojis() != emojiList
    }
    
    func getBackgroundColor(_ item: String) -> Color {
        if isInRemovingState {
            if isItemDeleteable(item) {
                return Color(UIColor(.red).withAlphaComponent(0.3))
            }
        }
        if pressedItem == item {
            return pressedButtonColor
        }
        return .clear
    }
    
    @ViewBuilder
    var body: some View {
        VStack {
            if thereAreItemsLeftToBeDeleted() == true {
                Button {
                    isInRemovingState.toggle()
                } label: {
                    Text(!isInRemovingState ? "Remove emoji" : "Done")
                        .frame(maxWidth: .infinity)
                }
                .tint(.clear)
                .foregroundColor(.red)
                .buttonStyle(.bordered)
            }
            
            Text(String(String(pressedItemTopDisplay)))
                .font(.system(size: 150))
                .padding(.top, 50)
                .scaleEffect(CurrentlyPressedTopDisplayScale)
            Spacer()
            LazyVGrid(columns: adaptiveColumn, spacing: 0) {
                ForEach(getPresetAndUserEmojis(), id: \.self) { item in
                    Text(String(item))
                        .font(.system(size: 30))
                        .frame(maxWidth: .infinity, minHeight: buttonSize)
                        .background(getBackgroundColor(item))
                        .cornerRadius(4)
                        .foregroundColor(.white)
                        .scaleEffect(pressedItem == item ? 1.5 : 1)
                        .shaking($isInRemovingState, isItemDeleteable(item))
                        .onTapGesture {
                            if !isInRemovingState
                            {
                                UIPasteboard.general.string = item
                                vibrate()
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    pressedItem = item
                                }
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                    withAnimation(.easeInOut(duration: 0.2)) {
                                        pressedItem = nil
                                    }
                                }
                                
                                
                                for dispatchWorkItem in dispatchWorkItemArray {
                                    dispatchWorkItem.cancel()
                                }
                                
                                
                                var newWorkItem: DispatchWorkItem
                                
                                if isHeaderEmojiVisible == true {
                                    isHeaderEmojiVisible = false
                                    
                                    withAnimation(.easeInOut(duration: animationDuration)) {
                                        CurrentlyPressedTopDisplayScale = 0
                                    }
                                    
                                    newWorkItem = DispatchWorkItem {
                                        pressedItemTopDisplay = item
                                        isHeaderEmojiVisible = true
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 1
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: newWorkItem)
                                    
                                    
                                    newWorkItem = DispatchWorkItem {
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 0
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                    
                                    
                                    newWorkItem = DispatchWorkItem {
                                        isHeaderEmojiVisible = false
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: newWorkItem)
                                    
                                    
                                    
                                } else {
                                    pressedItemTopDisplay = item
                                    isHeaderEmojiVisible = true
                                    withAnimation(.easeInOut(duration: animationDuration)) {
                                        CurrentlyPressedTopDisplayScale = 1
                                    }
                                    newWorkItem = DispatchWorkItem {
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 0
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                    
                                    newWorkItem = DispatchWorkItem {
                                        isHeaderEmojiVisible = false
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                }
                            } else {
                                let dataItemIndexToRemove = emojiLocalStorageItemsList.firstIndex(where: {$0.emojiValue == item})
                                if dataItemIndexToRemove != nil {
                                    context.delete(emojiLocalStorageItemsList[dataItemIndexToRemove!])
                                }
                                if emojiLocalStorageItemsList.count == 1 && dataItemIndexToRemove != nil {
                                    isInRemovingState = false
                                }
                            }
                        }
                }
            }.padding(.bottom, 50)
            Button {
                showPopover = true
            } label: {
                Text("Add new emoji")
                    .frame(maxWidth: .infinity)
            }
            .tint(.clear)
            .foregroundColor(.gray)
            .buttonStyle(.bordered)
            .padding(.leading, 50).padding(.trailing, 50)
            .emojiPalette(selectedEmoji: $emoji.onChange(addItem),
                           isPresented: $showPopover)
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
            ForEach(ColorScheme.allCases, id: \.self, content: ContentView().preferredColorScheme)
        }
}
