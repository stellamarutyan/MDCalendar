import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        let dailyEvents = viewModel.events(for: viewModel.selectedDate)
        
        VStack(spacing: 0) {
                // Day Navigation Header
                HStack {
                    Button(action: { viewModel.changeDate(by: -1) }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .padding()
                    }
                    
                    Spacer()
                    
                    VStack {
                        Text(formatDate(viewModel.selectedDate))
                            .font(.title2)
                            .fontWeight(.bold)
                        if viewModel.isToday(viewModel.selectedDate) {
                            Text("Today")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .onTapGesture {
                        // Return to today on tap
                        viewModel.selectedDate = Calendar.current.startOfDay(for: Date())
                    }
                    
                    Spacer()
                    
                    Button(action: { viewModel.changeDate(by: 1) }) {
                        Image(systemName: "chevron.right")
                            .font(.title2)
                            .padding()
                    }
                }
                .padding(.horizontal)
                .background(backgroundColor(for: dailyEvents).ignoresSafeArea(edges: .top))
                
                Divider()
                
                // Events List for Selected Day
                
                if dailyEvents.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(dailyEvents) { event in
                                EventRowView(event: event, cachedSchedule: viewModel.cachedBlockSchedules[event.id])
                                    .padding(.horizontal)
                                Divider()
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .onAppear {
                viewModel.fetchEvents()
            }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
    
    private func backgroundColor(for events: [SchoolEvent]) -> Color {
        print("--- Debugging Events in backgroundColor ---")
        for event in events {
            print("Title: '\(event.title)' | Categories: \(event.categories)")
            if event.categories.contains("Block Schedule") {
                let upperTitle = event.title.uppercased()
                if upperTitle.hasPrefix(" GRAY") {
                    return Color(red: 84/255.0, green: 88/255.0, blue: 90/255.0)
                } else if upperTitle.hasPrefix(" RED") {
                    return Color(red: 183/255.0, green: 28/255.0, blue: 28/255.0)
                }
            }
        }
        return Color.gray.opacity(0.1)
    }
}
