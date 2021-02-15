import Foundation

struct Memo: Decodable {
    let title: String
    let body: String
    private let lastModified: Int
    
    var lastModifiedDate: Date {
        return Date(timeIntervalSinceReferenceDate: TimeInterval(lastModified))
    }
    
    enum CodingKeys: String, CodingKey {
        case title, body
        case lastModified = "last_modified"
    }

}
