import Foundation

class CalendarParser {
    static func parse(icsContent: String) -> [SchoolEvent] {
        var events: [SchoolEvent] = []
        
        // 1. Unfold lines (handle ICS multi-line values)
        var unfoldedLines: [String] = []
        let rawLines = icsContent.components(separatedBy: .newlines)
        
        for line in rawLines {
            if line.isEmpty { continue }
            
            if line.hasPrefix(" ") || line.hasPrefix("\t") {
                // It's a continuation of the previous line
                if var last = unfoldedLines.last {
                    // Remove the leading space/tab and append
                    let index = line.index(after: line.startIndex)
                    last += String(line[index...])
                    unfoldedLines[unfoldedLines.count - 1] = last
                }
            } else {
                unfoldedLines.append(line.trimmingCharacters(in: .whitespacesAndNewlines)) // trimming only end basically, but start is not space
            }
        }
        
        var inEvent = false
        var currentEventData: [String: String] = [:]
        
        for line in unfoldedLines {
            if line == "BEGIN:VEVENT" {
                inEvent = true
                currentEventData = [:]
                continue
            }
            
            if line == "END:VEVENT" {
                if let event = createEvent(from: currentEventData) {
                    events.append(event)
                }
                inEvent = false
                continue
            }
            
            if inEvent {
                // Split by first colon
                if let range = line.range(of: ":") {
                    let keyPart = String(line[..<range.lowerBound])
                    let value = String(line[range.upperBound...])
                    
                    // Handle parameters in key (e.g. DTSTART;VALUE=DATE)
                    let key = keyPart.components(separatedBy: ";").first ?? keyPart
                    
                    // We store the generic key. If duplicate keys exist (like multiple CATEGORIES lines), 
                    // we might overwrite. Standard VEVENT usually has one summary, one desc. 
                    // Categories might be multiple, but we'll assume one line or comma separated.
                    currentEventData[key] = value
                }
            }
        }
        
        return events
    }
    
    private static func createEvent(from data: [String: String]) -> SchoolEvent? {
        let summary = data["SUMMARY"]?.unescaped() ?? "No Title"
        
        // Date Parsing
        // Try DTSTART first. If missing, skip.
        guard let dtStartStr = data["DTSTART"] else { return nil }
        
        let isAllDay = dtStartStr.count == 8 // Simple check for YYYYMMDD
        let date = parseDate(dtStartStr, isAllDay: isAllDay) ?? Date()
        
        // Time & Location String construction
        var timeLocationString = ""
        if isAllDay {
            timeLocationString = "All Day"
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "h:mm a"
            timeLocationString = formatter.string(from: date)
            
            if let dtEndStr = data["DTEND"],
               let endDate = parseDate(dtEndStr, isAllDay: false) {
                 timeLocationString += " - " + formatter.string(from: endDate)
            }
        }
        
        if let location = data["LOCATION"]?.unescaped(), !location.isEmpty {
            timeLocationString += " (\(location))"
        }
        
        // Categories
        var categories: [String] = []
        if let catStr = data["CATEGORIES"] ?? data["Categories"] {
            categories = catStr.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces).unescaped() }
        }
        
        // Description
        // Keep HTML tags, but unescape ICS characters
        let rawDescription = data["DESCRIPTION"] ?? ""
        let description = rawDescription.unescaped()
        
        // URL
        // Sometimes URL is in URL field, sometimes in description? ICS standard has URL field.
        var detailsURL: URL?
        if let urlStr = data["URL"] {
             detailsURL = URL(string: urlStr)
        }

        return SchoolEvent(
            title: summary,
            date: date,
            timeLocationString: timeLocationString,
            categories: categories,
            description: description,
            detailsURL: detailsURL
        )
    }
    
    private static func parseDate(_ dateStr: String, isAllDay: Bool) -> Date? {
        let formatter = DateFormatter()
        if isAllDay {
            formatter.dateFormat = "yyyyMMdd"
            return formatter.date(from: dateStr)
        } else {
            // Remove 'Z' if present for default timezone (simplification)
            let cleanStr = dateStr.replacingOccurrences(of: "Z", with: "")
            formatter.dateFormat = "yyyyMMdd'T'HHmmss"
            return formatter.date(from: cleanStr)
        }
    }
}

extension String {
    func unescaped() -> String {
        return self.replacingOccurrences(of: "\\n", with: "\n")
                   .replacingOccurrences(of: "\\,", with: ",")
                   .replacingOccurrences(of: "\\;", with: ";")
                   .replacingOccurrences(of: "\\\\", with: "\\")
    }
}
