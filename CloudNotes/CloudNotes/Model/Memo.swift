import Foundation

struct Memo: Decodable {
    let title: String
    let body: String
    private let lastModified: Int
    
    var lastModifiedDate: Date {
        return Date(timeIntervalSince1970: TimeInterval(lastModified))
    }
    
    enum CodingKeys: String, CodingKey {
        case title, body
        case lastModified = "last_modified"
    }

}
