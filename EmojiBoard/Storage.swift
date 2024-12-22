//
//  Storage.swift
//  EmojiBoard
//
//  Created by Oleh Kopyl on 22.12.2024.
//

import Foundation
import SwiftData

@available(iOS 17.0, *)
@Model
class DataItem: Identifiable {
    var id: String
    var emojiValue: String
    var timeStampCreated: Double
    
    init(emojiValue: String) {
        self.id = UUID().uuidString
        self.emojiValue = emojiValue
        self.timeStampCreated = Date.now.timeIntervalSince1970
    }
}
