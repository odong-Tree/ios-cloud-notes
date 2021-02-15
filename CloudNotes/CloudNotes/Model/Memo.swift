import Foundation

struct Memo: Decodable {
    let title: String
    let body: String
    private let lastModified: Int

}
