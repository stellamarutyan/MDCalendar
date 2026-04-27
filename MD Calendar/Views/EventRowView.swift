import SwiftUI

struct EventRowView: View {
    let event: SchoolEvent
    var cachedSchedule: [BlockScheduleItem]? = nil
    
    @State private var isExpanded = false
    @State private var showingSafari = false
    @State private var showingBlockSettings = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main Row Content (Tappable Header)
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
            .contentShape(Rectangle())
            .onTapGesture {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            }
            
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
                                HStack {
                                    if item.isSubBlock { 
                                        Spacer().frame(width: 20) 
                                    }
                                    Text(item.name)
                                        .fontWeight(item.isSubBlock ? .regular : .semibold)
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
}
