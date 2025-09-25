//
//  MessageData.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/24.
//

import Foundation
import UIKit

struct Message {
    let text: String
    let sender: Sender
}

enum Sender {
    case user
    case bot
}
