//
//  NetworkConfiguration.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/24.
//

import Foundation
import SwiftHelpers

struct NetworkConfiguration {
        
    enum Scheme: String {
        
        case http = "http://"
        
        case https = "https://"
        
        case websocket = "ws://"
    }
    
    enum Server {
        
        /// ADK API Server
        case adk
        
        var host: String {
            switch self {
            case .adk:
                return "YOUR IP Ex:http://192.168....."
            }
        }
    }
}
extension NetworkConfiguration.Server {
    func webSocketURL(path: String) -> URL? {
        let wsBase = host.replacingOccurrences(of: "http://", with: "ws://")
        return URL(string: wsBase + path)
    }
}

enum NetworkError: Error {
    
    /// 錯誤的 URL 格式
    case badURLFormat
    
    /// 錯誤的 URLRequest Body
    case badRequestJSONBody
    
    /// 錯誤的 HTTP Response
    case badResponse
    
    /// 無預期的 HTTP Status
    case unexpected(HTTP.StatusCode)
    
    /// 未知的 HTTP Status
    case unknownStatus(HTTP.StatusCode)
    
    /// JSON 解碼失敗
    case jsonDecodedFailed(DecodingError)
}

// API 的網址
enum APIPath: String {
    
    case session = "/apps/multi_tool_agent/users/u_123/sessions/s_123"
    
    case run = "/run"
}
