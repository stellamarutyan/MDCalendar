import Foundation
import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var eventsByDate: [Date: [SchoolEvent]] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    var dates: [Date] {
        eventsByDate.keys.sorted()
    }
    
    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    func events(for date: Date) -> [SchoolEvent] {
        let events = eventsByDate[date] ?? []
        return events.sorted { $0.date < $1.date }
    }
    
    func fetchEvents() {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let fetcher = CalendarFetcher()
                // ICS URL
                let urlString = "https://www.materdei.org/apps/events/ical/?id=0&id=1&id=10&id=11&id=12&id=2&id=3&id=5&id=6&id=7&id=8&id=9"
                guard let url = URL(string: urlString) else {
                    throw URLError(.badURL)
                }
                
                let icsString = try await fetcher.fetchCalendarHTML(url: url) // reusing method name for now, though it fetches ICS
                let events = CalendarParser.parse(icsContent: icsString)
                
                let calendar = Calendar.current
                let grouped = Dictionary(grouping: events) { event -> Date in
                    return calendar.startOfDay(for: event.date)
                }
                
                DispatchQueue.main.async {
                    self.eventsByDate = grouped
                    self.isLoading = false
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                    self.isLoading = false
                    print("Error fetching events: \(error)")
                }
            }
        }
    }
}
