//
//  EmojiBoardApp.swift
//  EmojiBoard
//
//  Created by Oleh Kopyl on 20.12.2024.
//

import SwiftUI
import SwiftData

@available(iOS 17.0, *)
@main
struct EmojiBoardApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: DataItem.self)
    }
}
