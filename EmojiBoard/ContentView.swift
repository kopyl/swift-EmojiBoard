import SwiftUI

let spacing: CGFloat = 5
let buttonSize: CGFloat = 50
let emojiList = ["👍️️️️️️", "❤️", "😍", "🔥", "✅", "❌", "🤔", "🤡", "😄", "🤮", "🙏", "🚫", "😂", "😭", "🤬", "😀", "🍌", "🥰", "🚩", "👇", "☝️"]
let animationDuration = 0.1

func vibrate() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.prepare()
    generator.impactOccurred()
}

struct ContentView: View {

    private let adaptiveColumn = [
        GridItem(.adaptive(minimum: buttonSize-spacing), spacing: spacing)
    ]

    @State private var pressedItem: String? = nil
    @State private var isHeaderEmojiVisible: Bool = false
    @State private var pressedItemTopDisplay: String = "❤️"
    
    @State private var backgroundColor: Color = Color(UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 0.05))
    @State private var pressedButtonColor: Color = Color(UIColor(red: 1.00, green: 1.00, blue: 1.00, alpha: 1))
    
    @State private var dispatchWorkItemArray: Array<DispatchWorkItem> = []
    
    @State private var CurrentlyPressedTopDisplayScale: CGFloat = 0

    var body: some View {
        VStack {
            Text(String(String(pressedItemTopDisplay)))
                .font(.system(size: 150))
                .padding(.top, 50)
                .scaleEffect(CurrentlyPressedTopDisplayScale)
            Spacer()
                LazyVGrid(columns: adaptiveColumn, spacing: 5) {
                    ForEach(emojiList, id: \.self) { item in
                        Text(String(item))
                            .frame(width: buttonSize, height: buttonSize, alignment: .center)
                            .background(pressedItem == item ? pressedButtonColor : backgroundColor)
                            .cornerRadius(4)
                            .foregroundColor(.white)
                            .scaleEffect(pressedItem == item ? 1.5 : 1)
                            .onTapGesture {
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
                                    print("Making invisible top 1", Date.now.timeIntervalSince1970)
                                    
                                    withAnimation(.easeInOut(duration: animationDuration)) {
                                        CurrentlyPressedTopDisplayScale = 0
                                        print("Downscaling top 1", Date.now.timeIntervalSince1970)
                                    }
                                    
                                    newWorkItem = DispatchWorkItem {
                                        pressedItemTopDisplay = item
                                        isHeaderEmojiVisible = true
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 1
                                            print("Upscaling top 1", Date.now.timeIntervalSince1970)
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + animationDuration, execute: newWorkItem)
                                    
                                    
                                    newWorkItem = DispatchWorkItem {
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 0
                                            print("Downscaling top 2", Date.now.timeIntervalSince1970)
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                    
                                    
                                    newWorkItem = DispatchWorkItem {
                                        isHeaderEmojiVisible = false
                                        print("Making invisible top 2", Date.now.timeIntervalSince1970)
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.1, execute: newWorkItem)



                                } else {
                                    pressedItemTopDisplay = item
                                    isHeaderEmojiVisible = true
                                    withAnimation(.easeInOut(duration: animationDuration)) {
                                        CurrentlyPressedTopDisplayScale = 1
                                        print("Upscaling bottom", Date.now.timeIntervalSince1970)
                                    }
                                    newWorkItem = DispatchWorkItem {
                                        withAnimation(.easeInOut(duration: animationDuration)) {
                                            CurrentlyPressedTopDisplayScale = 0
                                            print("Downscaling bottom", Date.now.timeIntervalSince1970)
                                        }
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                    
                                    newWorkItem = DispatchWorkItem {
                                        isHeaderEmojiVisible = false
                                        print("Making invisible bottom", Date.now.timeIntervalSince1970)
                                    }
                                    dispatchWorkItemArray.append(newWorkItem)
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: newWorkItem)
                                }                                    
                            }
                    }
                }.padding(.bottom, 50)
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
