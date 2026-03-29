import SwiftUI

struct EventRowView: View {
    let event: SchoolEvent
    
    @State private var isExpanded = false
    @State private var showingSafari = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main Row Content (Tappable Header)
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(event.title)
                        .font(.headline)
                        .foregroundColor(.primary)
                        .fixedSize(horizontal: false, vertical: true) // Allow multiline title
                    
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
                    if !event.description.isEmpty {
                        HTMLTextView(htmlContent: event.description)
                            .frame(minHeight: 20) 
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
    }
}
