import SwiftUI

struct EventRowView: View {
    let event: SchoolEvent
    var cachedSchedule: [BlockScheduleItem]? = nil
    
    @State private var isExpanded = false
    @State private var showingSafari = false
    @State private var showingBlockSettings = false
    
    @AppStorage("block1Setting") private var block1: String = ""
    @AppStorage("block2Setting") private var block2: String = ""
    @AppStorage("block3Setting") private var block3: String = ""
    @AppStorage("block4Setting") private var block4: String = ""
    @AppStorage("block5Setting") private var block5: String = ""
    @AppStorage("block6Setting") private var block6: String = ""
    @AppStorage("block7Setting") private var block7: String = ""
    @AppStorage("block8Setting") private var block8: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main Row Content (Tappable Header)
            Button(action: {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(event.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                                .fixedSize(horizontal: false, vertical: true) // Allow multiline title
                            
                            if isConfigurableBlock(event: event) {
                                Button(action: {
                                    showingBlockSettings = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                                .buttonStyle(BorderlessButtonStyle())
                            }
                        }
                        
                        Text(event.timeLocationString)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // Expand Icon
                    Image(systemName: "chevron.down")
                        .foregroundColor(.gray)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
            }
            .buttonStyle(.plain)
            
            // Expanded Details
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    if !event.description.isEmpty && cachedSchedule == nil {
                        HTMLTextView(htmlContent: event.description)
                            .frame(minHeight: 20) 
                    }
                    
                    if let schedule = cachedSchedule, !schedule.isEmpty {
                        VStack(alignment: .leading, spacing: 6) {
                            ForEach(schedule) { item in
                                let parts = splitName(customName(for: item.name))
                                HStack(alignment: .top) {
                                    Text(parts.primary)
                                        .fontWeight(.semibold)
                                        .frame(width: 110, alignment: .topLeading)
                                        .fixedSize(horizontal: false, vertical: true)
                                    
                                    if !parts.secondary.isEmpty {
                                        Text(parts.secondary)
                                            .fontWeight(.semibold)
                                    }
                                    Spacer()
                                    Text(item.timeString)
                                        .foregroundColor(.secondary)
                                }
                                .font(.subheadline)
                                Divider()
                            }
                        }
                        .padding()
                        .background(Color(UIColor.secondarySystemBackground))
                        .cornerRadius(8)
                    }
                    
                    if let url = event.detailsURL {
                        Button(action: {
                            showingSafari = true
                        }) {
                            HStack {
                                Image(systemName: "safari")
                                Text("View Full Schedule & Details")
                            }
                            .font(.subheadline)
                            .foregroundColor(.blue)
                            .padding(.vertical, 4)
                        }
                        .sheet(isPresented: $showingSafari) {
                            SafariView(url: url)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
            
            // Categories
            if !event.categories.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(event.categories, id: \.self) { category in
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(CategoryColor.color(for: category))
                                .foregroundColor(CategoryColor.textColor(for: category))
                                .cornerRadius(4)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .sheet(isPresented: $showingBlockSettings) {
            BlockSettingsView()
        }
    }
    
    private func isConfigurableBlock(event: SchoolEvent) -> Bool {
        guard event.categories == ["Block Schedule"] else { return false }
        
        let pattern = "\\b[1-8]\\b"
        if let regex = try? NSRegularExpression(pattern: pattern) {
            let matches = regex.matches(in: event.title, range: NSRange(event.title.startIndex..., in: event.title))
            return matches.count >= 2
        }
        return false
    }
    
    private func customName(for blockName: String) -> String {
        var result = blockName
        
        let patternToBlock = [
            ("block\\s*1", block1, "B1"),
            ("block\\s*2", block2, "B2"),
            ("block\\s*3", block3, "B3"),
            ("block\\s*4", block4, "B4"),
            ("block\\s*5", block5, "B5"),
            ("block\\s*6", block6, "B6"),
            ("block\\s*7", block7, "B7"),
            ("block\\s*8", block8, "B8")
        ]
        
        for (pattern, setting, prefix) in patternToBlock {
            if !setting.isEmpty {
                if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
                    let range = NSRange(result.startIndex..., in: result)
                    if regex.firstMatch(in: result, range: range) != nil {
                        result = regex.stringByReplacingMatches(in: result, options: [], range: range, withTemplate: "\(prefix) (\(setting))")
                    }
                }
            }
        }
        
        return result
    }
    
    private func splitName(_ text: String) -> (primary: String, secondary: String) {
        // First try splitting by 2 or more spaces
        if let match = text.range(of: " {2,}", options: .regularExpression) {
            let p = String(text[..<match.lowerBound]).trimmingCharacters(in: .whitespaces)
            let s = String(text[match.upperBound...]).trimmingCharacters(in: .whitespaces)
            return (p, s)
        }
        
        // If that fails, look for Upper/Lower/Assembly keywords
        if let match = text.range(of: "Upper |Lower |Assembly", options: .regularExpression) {
            if match.lowerBound != text.startIndex {
                let p = String(text[..<match.lowerBound]).trimmingCharacters(in: .whitespaces)
                let s = String(text[match.lowerBound...]).trimmingCharacters(in: .whitespaces)
                return (p, s)
            } else {
                return ("", text.trimmingCharacters(in: .whitespaces))
            }
        }
        
        return (text, "")
    }
}
