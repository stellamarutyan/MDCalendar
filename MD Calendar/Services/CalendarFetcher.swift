import Foundation

class CalendarFetcher {
    private let session: URLSession
    
    init() {
        let config = URLSessionConfiguration.default
        // Use a common browser User-Agent to avoid 403 Forbidden
        config.httpAdditionalHeaders = [
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
        ]
        self.session = URLSession(configuration: config)
    }
    
    func fetchCalendarHTML(url: URL) async throws -> String {
        let (data, response) = try await session.data(from: url)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            print("Status Code: \(httpResponse.statusCode)")
            throw URLError(.badServerResponse) // simplified error
        }
        
        guard let html = String(data: data, encoding: .utf8) else {
            throw URLError(.cannotDecodeContentData)
        }
        
        return html
    }
}
