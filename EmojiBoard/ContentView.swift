//
//  ContentView.swift
//  EmojiBoard
//

//  Created by Oleh Kopyl on 20.12.2024.
//

let emojiList = ["❤️", "🔥"]

import SwiftUI

struct ContentView: View {
    @State var selection: String = emojiList[0]
    
    var body: some View {
        VStack {
            Text(selection).font(.system(size: 100))
            
            Picker("Select emoji", selection: $selection) {
                ForEach(emojiList, id: \.self) {
                    emoji in Text(emoji)
                }
            }
            .pickerStyle(.wheel)
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
