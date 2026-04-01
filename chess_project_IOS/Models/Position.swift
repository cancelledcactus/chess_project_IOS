import Foundation

struct Position: Hashable, Codable {
    let row: Int
    let col: Int

    var isValid: Bool {
        (0..<8).contains(row) && (0..<8).contains(col)
    }

    var algebraic: String {
        let file = String(UnicodeScalar(97 + col)!)
        let rank = String(8 - row)
        return file + rank
    }

    static func from(file: Int, rank: Int) -> Position {
        Position(row: 8 - rank, col: file)
    }
}
