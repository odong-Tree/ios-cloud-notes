import Foundation

enum CloudFile {
    static let requiredScope = ["files.content.read", "files.content.write"]
    static let fileNames = ["/CloudNotes.sqlite", "/CloudNotes.sqlite-wal", "/CloudNotes.sqlite-shm"]
}
