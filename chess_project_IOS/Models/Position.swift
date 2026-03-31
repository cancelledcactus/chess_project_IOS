import Foundation

struct Position: Equatable, Codable, Hashable {
    let row: Int
    let col: Int

    var isValid: Bool {
        (0..<8).contains(row) && (0..<8).contains(col)
    }

    var algebraic: String {
        let files = ["a", "b", "c", "d", "e", "f", "g", "h"]
        return "\(files[col])\(8 - row)"
    }
}
