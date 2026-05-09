import Foundation
import SwiftUI
import Combine

@MainActor
class CalendarViewModel: ObservableObject {
    @Published var selectedDate: Date = Calendar.current.startOfDay(for: Date())
    @Published var eventsByDate: [Date: [SchoolEvent]] = [:]
    @Published var cachedBlockSchedules: [UUID: (schedule: [BlockScheduleItem], fetchTime: Date)] = [:]
    @Published var isLoading = false
    @Published var errorMessage: String?
    private var lastCalendarFetchTime: Date?
    
    @Published var hiddenCategories: Set<String> = [] {
        didSet {
            if let data = try? JSONEncoder().encode(hiddenCategories) {
                UserDefaults.standard.set(data, forKey: "hiddenCategories")
            }
        }
    }
    
    init() {
        if let data = UserDefaults.standard.data(forKey: "hiddenCategories"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.hiddenCategories = decoded
        }
    }
    
    var dates: [Date] {
        eventsByDate.keys.sorted()
    }
    
    func changeDate(by days: Int) {
        if let newDate = Calendar.current.date(byAdding: .day, value: days, to: selectedDate) {
            selectedDate = newDate
            prefetchBlockDetails(for: newDate)
        }
    }
    
    func isToday(_ date: Date) -> Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var availableCategories: [String] {
        var cats = Set<String>()
        for events in eventsByDate.values {
            for event in events {
                cats.formUnion(event.categories)
            }
        }
        return Array(cats).sorted()
    }
    
    func events(for date: Date) -> [SchoolEvent] {
        let allEvents = eventsByDate[date] ?? []
        return allEvents.filter { event in
            if event.categories.isEmpty { return true }
            return !event.categories.allSatisfy { hiddenCategories.contains($0) }
        }.sorted { $0.date < $1.date }
    }
    
    func fetchEvents() {
        guard !isLoading else { return }
        
        let now = Date()
        if let lastFetch = lastCalendarFetchTime, now.timeIntervalSince(lastFetch) < 3 * 3600 {
            // Main calendar is fresh. Just ensure current block schedule isn't stale.
            prefetchBlockDetails(for: selectedDate)
            return
        }
        
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
                    self.lastCalendarFetchTime = Date()
                    self.eventsByDate = grouped
                    self.isLoading = false
                    self.prefetchBlockDetails(for: self.selectedDate)
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
    func syncIfNeeded() {
        fetchEvents()
    }
    
    private func prefetchBlockDetails(for date: Date) {
        let eventsOnDate = events(for: date)
        let now = Date()
        
        for event in eventsOnDate {
            if event.categories.contains("Block Schedule"), let url = event.detailsURL {
                var needsFetch = true
                
                if let cached = cachedBlockSchedules[event.id] {
                    if now.timeIntervalSince(cached.fetchTime) < 3 * 3600 {
                        needsFetch = false
                    }
                }
                
                if needsFetch {
                    Task {
                        do {
                            let fetcher = CalendarFetcher()
                            let html = try await fetcher.fetchCalendarHTML(url: url)
                            let parsedSchedule = HTMLTableParser.parseSchedule(from: html)
                            DispatchQueue.main.async {
                                self.cachedBlockSchedules[event.id] = (parsedSchedule, Date())
                            }
                        } catch {
                            print("Error prefetching block schedule: \(error)")
                        }
                    }
                }
            }
        }
    }
}
