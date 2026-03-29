import Foundation

struct SchoolEvent: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let date: Date // Represents the date of the event (ignoring time component for grouping)
    let timeLocationString: String
    let categories: [String]
    let description: String
    let detailsURL: URL?
    
    // Custom formatted date string for display
    var dateString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, EEEE"
        return formatter.string(from: date)
    }
    
    init(id: UUID = UUID(), title: String, date: Date, timeLocationString: String, categories: [String], description: String = "", detailsURL: URL? = nil) {
        self.id = id
        self.title = title
        self.date = date
        self.timeLocationString = timeLocationString
        self.categories = categories
        self.description = description
        self.detailsURL = detailsURL
    }
}
