import Foundation

enum PieceColor: String, Codable, CaseIterable {
    case white
    case black

    var opposite: PieceColor {
        self == .white ? .black : .white
    }

    var displayName: String {
        rawValue.capitalized
    }
}

enum PieceType: String, Codable, CaseIterable {
    case king
    case queen
    case rook
    case bishop
    case knight
    case pawn
}

struct Piece: Equatable, Codable, Hashable {
    let type: PieceType
    let color: PieceColor

    var symbol: String {
        switch (color, type) {
        case (.white, .king): return "white-king"
        case (.white, .queen): return "white-queen"
        case (.white, .rook): return "white-rook"
        case (.white, .bishop): return "white-bishop"
        case (.white, .knight): return "white-knight"
        case (.white, .pawn): return "white-pawn"
        case (.black, .king): return "black-king"
        case (.black, .queen): return "black-queen"
        case (.black, .rook): return "black-rook"
        case (.black, .bishop): return "black-bishop"
        case (.black, .knight): return "black-knight"
        case (.black, .pawn): return "black-pawn"
        }
    }
}



