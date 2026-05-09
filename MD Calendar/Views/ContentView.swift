import SwiftUI


struct ContentView: View {
    @Environment(\.scenePhase) var scenePhase
    @StateObject private var viewModel = CalendarViewModel()
    @State private var showingSettings = false
    
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
                .padding(.bottom, 10)
                .background(backgroundColor(for: dailyEvents).ignoresSafeArea(edges: .top))
                
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(height: 1)
                    .allowsHitTesting(false)
                
                // Events List for Selected Day
                
                if viewModel.isLoading && viewModel.eventsByDate.isEmpty {
                    VStack {
                        Spacer()
                        ProgressView()
                            .scaleEffect(1.5)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if dailyEvents.isEmpty {
                    VStack {
                        Spacer()
                        Text("No events scheduled")
                            .foregroundColor(.secondary)
                            .font(.title3)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            ForEach(dailyEvents) { event in
                                EventRowView(event: event, cachedSchedule: viewModel.cachedBlockSchedules[event.id]?.schedule)
                                    .padding(.horizontal)
                                Rectangle()
                                    .fill(Color.gray.opacity(0.3))
                                    .frame(height: 1)
                                    .allowsHitTesting(false)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .onAppear {
                viewModel.fetchEvents()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    viewModel.syncIfNeeded()
                }
            }
            .gesture(
                DragGesture(minimumDistance: 40)
                    .onEnded { value in
                        // Only trigger if the drag is primarily horizontal
                        if abs(value.translation.width) > abs(value.translation.height) {
                            if value.translation.width < 0 {
                                // Swiped left -> Next day
                                viewModel.changeDate(by: 1)
                            } else if value.translation.width > 0 {
                                // Swiped right -> Previous day
                                viewModel.changeDate(by: -1)
                            }
                        }
                    }
            )
            .sheet(isPresented: $showingSettings) {
                SettingsView(viewModel: viewModel)
            }
            .overlay(alignment: .bottomTrailing) {
                Button(action: { showingSettings = true }) {
                    Image(systemName: "slider.horizontal.3")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding(12)
                        .background(Color(red: 183/255.0, green: 28/255.0, blue: 28/255.0))
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.3), radius: 4, x: 0, y: 2)
                }
                .padding(.trailing, 15)
                .padding(.bottom, 15)
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
