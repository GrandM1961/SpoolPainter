import Foundation
import Combine

class SpoolmanClient {
    static let shared = SpoolmanClient()
    private init() {}
    
    func fetchFilaments(urlString: String) -> AnyPublisher<[Filament], Error> {
        var s = urlString.trimmingCharacters(in: .whitespacesAndNewlines)
        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "http://\(s)" }
        guard let url = URL(string: s + "/api/v1/filament") else { return Fail(error: URLError(.badURL)).eraseToAnyPublisher() }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .tryMap { data, resp in
                if let http = resp as? HTTPURLResponse, !(200..<300 ~= http.statusCode) {
                    throw URLError(.badServerResponse)
                }
                if let s = String(data: data, encoding: .utf8) {
                    print("Spoolman response:", s) // <-- hier de raw JSON
                } else {
                    print("Spoolman response: <non-utf8 data>")
                }
                return data
            }
            .decode(type: [Filament].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .eraseToAnyPublisher()
    }
    
    func parseColorName(from productName: String) -> String {
        let candidates = ["black","white","red","blue","yellow","green","orange","pink","purple","brown","gray","grey"]
        let parts = productName.lowercased().split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }
        for p in parts.reversed() {
            if candidates.contains(p) { return p.capitalized }
        }
        if let last = parts.last, last.rangeOfCharacter(from: CharacterSet.letters) != nil {
            return last.capitalized
        }
        return ""
    }
}
