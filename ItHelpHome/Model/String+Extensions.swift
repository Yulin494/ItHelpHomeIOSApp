//
//  String+Extensions.swift
//  ItHelpHome
//
//  Created by imac on 2025/9/25.
//

import Foundation

extension String {
    var htmlToPlainText: String {
        // 1. 先將字串轉為 Data
        guard let data = self.data(using: .utf8) else {
            return self
        }
        
        var plainText = self
        
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [
                    .documentType: NSAttributedString.DocumentType.html,
                    .characterEncoding: String.Encoding.utf8.rawValue
                ],
                documentAttributes: nil
            )
            plainText = attributedString.string
        } catch {
            // 如果 HTML 解析失敗，我們還是可以繼續嘗試移除星號
            print("Could not parse HTML: \(error). Proceeding with raw text.")
        }
        
        let formattedText = plainText
            .replacingOccurrences(of: "*", with: "") // 將 * 替換為 •
            .trimmingCharacters(in: .whitespacesAndNewlines) // 清除頭尾的空白和換行

        return formattedText
    }
}
