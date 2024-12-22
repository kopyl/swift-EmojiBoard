import SwiftUI
import SwiftData

let spacing: CGFloat = 5
let buttonSize: CGFloat = 50
let emojiList = ["👍️️️️️️", "❤️", "😍", "🔥", "✅", "❌", "🤔", "🤡", "😄", "🤮", "🙏", "🚫", "😂", "😭", "🤬", "😀", "🍌", "🥰", "🚩", "👇", "☝️"]
let animationDuration = 0.1

func vibrate() {
    let generator = UIImpactFeedbackGenerator(style: .heavy)
    generator.prepare()
    generator.impactOccurred()
}

struct TextInputAlert: UIViewControllerRepresentable {
    @Binding var text: String
    @Binding var isPresented: Bool
    var title: String
    var message: String
    var placeholder: String
    var onTextEntered: (String) -> Void // Callback for reacting to text input
    
    class Coordinator: NSObject {
        var alert: TextInputAlert
        
        init(alert: TextInputAlert) {
            self.alert = alert
        }
        
        @objc func textChanged(_ textField: UITextField) {
            self.alert.text = textField.text ?? ""
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(alert: self)
    }
    
    func makeUIViewController(context: Context) -> UIViewController {
        return UIViewController() // Dummy controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        guard isPresented, uiViewController.presentedViewController == nil else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addTextField { textField in
            textField.placeholder = placeholder
            textField.text = text
            textField.addTarget(context.coordinator, action: #selector(Coordinator.textChanged(_:)), for: .editingChanged)
        }
        
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            self.isPresented = false
            self.onTextEntered(self.text) // React when the user finishes input
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            self.isPresented = false
        })
        
        uiViewController.present(alert, animated: true, completion: nil)
    }
}

// SwiftUI View Modifier for presenting the alert
extension View {
    func textInputAlert(isPresented: Binding<Bool>, text: Binding<String>, title: String, message: String, placeholder: String = "", onTextEntered: @escaping (String) -> Void) -> some View {
        self.background(
            TextInputAlert(
                text: text,
                isPresented: isPresented,
                title: title,
                message: message,
                placeholder: placeholder,
                onTextEntered: onTextEntered
            )
        )
    }
}

@available(iOS 17.0, *)
struct ContentView: View {
    
    @State private var isAlertPresented = false
    @State private var userInput = ""
    
    @Environment(\.modelContext) private var context
    @Query private var emojiLocalStorageItemsList: Array<DataItem>

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
    
    func addItem(emojiValue: String) {
        let item = DataItem(emojiValue: emojiValue)
        context.insert(item)
        userInput = ""
        try? context.delete(model: DataItem.self, where: #Predicate {$0.emojiValue.isEmpty})
//        for item in emojiLocalStorageItemsList {
//            print(item.emojiValue)
//        }
    }

    var body: some View {
        VStack {
            Text(String(String(pressedItemTopDisplay)))
                .font(.system(size: 150))
                .padding(.top, 50)
                .scaleEffect(CurrentlyPressedTopDisplayScale)
            Spacer()
            LazyVGrid(columns: adaptiveColumn, spacing: 5) {
                ForEach(emojiList + emojiLocalStorageItemsList.sorted(by: {$0.timeStampCreated < $1.timeStampCreated}).map({(item: DataItem) -> String in return item.emojiValue}), id: \.self) { item in
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
            HStack(spacing: 50) {
                Button("Delete all items") {
                    try? context.delete(model: DataItem.self, where: #Predicate {!$0.emojiValue.isEmpty})
                }.tint(.red)

                Button("Add item") {
                isAlertPresented = true
                }.textInputAlert(
                    isPresented: $isAlertPresented,
                    text: $userInput,
                    title: "Add your emoji",
                    message: "Add custom emoji to the list",
                    placeholder: "Emoji",
                    onTextEntered: addItem
                )
                Button("Print items") {
                    for item in emojiLocalStorageItemsList {
                        print(item.emojiValue, item.timeStampCreated)
                    }
                    print("")
                }
            }
        }
    }
}

@available(iOS 17.0, *)
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
