/*
 EmojiPaletteView.swift
 

 Created by Takuto Nakamura on 2023/09/11.
 
*/

import SwiftUI

public struct EmojiPaletteView: View {
    @Binding var selectedEmoji: String
    @State var emojiSets: [EmojiSet]
    @State var selection: EmojiCategory = .smileysAndPeople
    private let columns: [GridItem] = Array(repeating: .init(.flexible(), spacing: 8), count: 6)

    public init(selectedEmoji: Binding<String>) {
        _selectedEmoji = selectedEmoji
        emojiSets = EmojiParser.shared.emojiSets
    }

    public var body: some View {
        VStack(spacing: 0) {
            if let emojiSet = emojiSets.first(where: { $0.category == selection }) {
                List {
                    Section {
                        LazyVGrid(columns: columns, spacing: 8) {
                            ForEach(emojiSet.emojis) { emoji in
                                Button {
                                    selectedEmoji = emoji.character
                                } label: {
                                    Text(emoji.character)
                                        .font(.system(size: 26))
                                }
                                .buttonStyle(.borderless)
                                .frame(width: 32, height: 32)
                            }
                        }
                    } header: {
                        Text(emojiSet.category.label, bundle: .module)
                    }
                    .textCase(.none)
                }
                .listStyle(.plain)
                .id(selection)
            }
            Divider()
            HStack(spacing: 8) {
                ForEach(EmojiCategory.allCases) { emojiCategory in
                    Image(systemName: emojiCategory.imageName)
                        .font(.system(size: 18))
                        .frame(width: 24, height: 24)
                        .foregroundColor(selection == emojiCategory ? Color.accentColor : .secondary)
                        .onTapGesture {
                            selection = emojiCategory
                        }
                }
            }
            .padding(8)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    EmojiPaletteView(selectedEmoji: .constant(""))
}
