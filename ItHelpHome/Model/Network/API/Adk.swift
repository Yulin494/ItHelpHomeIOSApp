//
//  Adk.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/24.
//

import Foundation

// MARK: - Update Session API Request
struct UpdateSessionRequest: Codable {
    // 假設 state 的 value 都是 String，如果類型不固定，處理會更複雜
    // 為了簡單起見，我們先假設是 [String: String]
    let state: [String: String]
}

// MARK: - Update Session API Response

struct UpdateSessionResponse: Codable {
    let id: String
    let appName: String
    let userId: String
    let state: NestedState // 對應巢狀的 "state" 物件
    let events: [Event]    // 使用自訂的 Event 結構，以應對未來可能的複雜內容
    let lastUpdateTime: Double

    // 將 API 回應中的 snake_case (例如 app_name) 轉換為 Swift 的 camelCase (例如 appName)
    enum CodingKeys: String, CodingKey {
        case id
        case appName = "app_name"
        case userId = "user_id"
        case state
        case events
        case lastUpdateTime = "last_update_time"
    }
}

// 用來對應 "state" 欄位內部的巢狀結構
struct NestedState: Codable {
    let state: [String: AnyCodable]
}

// 雖然您提供的範例中 events 是空陣列，但為其建立一個結構是好的實踐
// 如果 events 內容很複雜，未來可以直接擴充這個 struct
struct Event: Codable {
    // 根據您 API 的實際內容在這裡定義屬性
    // 例如： let type: String, let timestamp: Double 等
}


// MARK: - Helper for Mixed-Type Dictionaries
// 用於處理 state 字典中 value 類型不固定的情況 (例如 String 和 Int)
struct AnyCodable: Codable {
    let value: Any

    init<T>(_ value: T?) {
        self.value = value ?? ()
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let int = try? container.decode(Int.self) {
            value = int
        } else if let double = try? container.decode(Double.self) {
            value = double
        } else if let string = try? container.decode(String.self) {
            value = string
        } else if let bool = try? container.decode(Bool.self) {
            value = bool
        } else if let array = try? container.decode([AnyCodable].self) {
            value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "AnyCodable value cannot be decoded")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let bool as Bool:
            try container.encode(bool)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyCodable value cannot be encoded"))
        }
    }
}

// MARK: - API 2: 發送訊息並執行
// 請求 (Request) - 這是比較複雜的結構，我們用巢狀 struct 來對應
struct SendMessageRequest: Codable {
    let appName: String
    let userId: String
    let sessionId: String
    let newMessage: MessagePayload

    // 使用 CodingKeys 來自動轉換 snake_case (API端) 為 camelCase (Swift端)
    enum CodingKeys: String, CodingKey {
        case appName = "app_name"
        case userId = "user_id"
        case sessionId = "session_id"
        case newMessage = "new_message"
    }
}

struct MessagePayload: Codable {
    let role: String // "user" 或 "assistant"
    let parts: [MessagePart]
}

struct MessagePart: Codable {
    let text: String
}


// MARK: - 發送訊息並執行 API 回應 (Response)
// 因為 API 的回應是一個陣列，所以我們先定義陣列中單一元素的結構
struct RunResponseElement: Codable {
    let content: RunContent
    let finishReason: String?
    // 其他欄位如 usageMetadata, invocationId 等，如果用不到可以省略
    
    enum CodingKeys: String, CodingKey {
        case content
        case finishReason = "finish_reason"
    }
}

struct RunContent: Codable {
    let parts: [RunPart]
    let role: String
}

// "parts" 陣列中的元素可以是不同類型，我們需要一個 enum 來處理
// 它可以是包含文字的、呼叫工具的、或工具回應的
struct RunPart: Codable {
    // 我們只關心最終答案的 "text"，所以將其設為可選
    let text: String?
    
    // 其他可能的欄位，如果需要處理可以加上
    // let functionCall: FunctionCall?
    // let functionResponse: FunctionResponse?
}


// MARK: - 最終使用的包裝類型
// 因為 API 的根物件是一個陣列，所以我們用 typealias 來表示
typealias SendMessageResponse = [RunResponseElement]
