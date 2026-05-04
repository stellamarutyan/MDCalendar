import Foundation

class HTMLTableParser {
    static func parseSchedule(from html: String) -> [BlockScheduleItem] {
        var items: [BlockScheduleItem] = []
        
        // Find MsoTableGrid
        let tablePattern = "<table[^>]*MsoTableGrid[^>]*>(.*?)</table>"
        guard let tableRegex = try? NSRegularExpression(pattern: tablePattern, options: [.dotMatchesLineSeparators, .caseInsensitive]),
              let tableMatch = tableRegex.firstMatch(in: html, range: NSRange(html.startIndex..., in: html)),
              let tableRange = Range(tableMatch.range(at: 1), in: html) else {
            return []
        }
        
        let tableHtml = String(html[tableRange])
        
        // Find all <tr>...</tr>
        let trPattern = "<tr[^>]*>(.*?)</tr>"
        guard let trRegex = try? NSRegularExpression(pattern: trPattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            return []
        }
        
        let trMatches = trRegex.matches(in: tableHtml, range: NSRange(tableHtml.startIndex..., in: tableHtml))
        
        let tdPattern = "<td[^>]*>(.*?)</td>"
        guard let tdRegex = try? NSRegularExpression(pattern: tdPattern, options: [.dotMatchesLineSeparators, .caseInsensitive]) else {
            return []
        }
        
        for trMatch in trMatches {
            guard let trRange = Range(trMatch.range(at: 1), in: tableHtml) else { continue }
            let trHtml = String(tableHtml[trRange])
            
            let tdMatches = tdRegex.matches(in: trHtml, range: NSRange(trHtml.startIndex..., in: trHtml))
            if tdMatches.count >= 2 {
                guard let td1Range = Range(tdMatches[0].range(at: 1), in: trHtml),
                      let td2Range = Range(tdMatches[1].range(at: 1), in: trHtml) else { continue }
                
                let td1Html = String(trHtml[td1Range])
                let td2Html = String(trHtml[td2Range])
                
                let isSubBlock = td1Html.contains("&nbsp;&nbsp;") || td1Html.contains("&#160;&#160;") || td1Html.contains("    ") || td1Html.contains("&emsp;")
                
                var name = td1Html.strippingHTML()
                var timeString = td2Html.strippingHTML()
                
                // Clean up any remaining entities
                name = name.replacingOccurrences(of: "&nbsp;", with: " ")
                           .replacingOccurrences(of: "&#160;", with: " ")
                           .replacingOccurrences(of: "&amp;", with: "&")
                           .trimmingCharacters(in: .whitespacesAndNewlines)
                timeString = timeString.replacingOccurrences(of: "&nbsp;", with: " ")
                                       .replacingOccurrences(of: "&#160;", with: " ")
                                       .replacingOccurrences(of: "&amp;", with: "&")
                                       .replacingOccurrences(of: "–", with: "-") // dash normalization
                                       .trimmingCharacters(in: .whitespacesAndNewlines)
                
                if !name.isEmpty {
                    items.append(BlockScheduleItem(name: name, timeString: timeString, isSubBlock: isSubBlock))
                }
            }
        }
        
        return items
    }
}

extension String {
    fileprivate func strippingHTML() -> String {
        return self.replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression, range: nil)
    }
}
