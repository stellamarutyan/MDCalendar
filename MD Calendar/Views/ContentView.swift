import SwiftUI


struct ContentView: View {
    @StateObject private var viewModel = CalendarViewModel()
    
    var body: some View {
        NavigationView {
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
                .background(Color.gray.opacity(0.1))
                
                Divider()
                
                // Events List for Selected Day
                let dailyEvents = viewModel.events(for: viewModel.selectedDate)
                
                if dailyEvents.isEmpty {
                    VStack {
                        Spacer()
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                            .padding()
                        Text("No events for this day")
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List {
                        ForEach(dailyEvents) { event in
                            EventRowView(event: event)
                        }
                    }
                    .listStyle(.automatic)
                }
            }
            .navigationTitle("Mater Dei Calendar")
            #if os(iOS)
            .navigationBarHidden(true) // Hide default nav bar to use our custom header
            #endif
            .onAppear {
                viewModel.fetchEvents()
            }
            .gesture(
                DragGesture(minimumDistance: 30, coordinateSpace: .local)
                    .onEnded { value in
                        if value.translation.width < 0 {
                            // Swipe Left -> Next Day
                            viewModel.changeDate(by: 1)
                        } else if value.translation.width > 0 {
                            // Swipe Right -> Previous Day
                            viewModel.changeDate(by: -1)
                        }
                    }
            )
        }
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMM d"
        return formatter.string(from: date)
    }
}
