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
        case (.white, .king): return "♔"
        case (.white, .queen): return "♕"
        case (.white, .rook): return "♖"
        case (.white, .bishop): return "♗"
        case (.white, .knight): return "♘"
        case (.white, .pawn): return "♙"
        case (.black, .king): return "♚"
        case (.black, .queen): return "♛"
        case (.black, .rook): return "♜"
        case (.black, .bishop): return "♝"
        case (.black, .knight): return "♞"
        case (.black, .pawn): return "black-pawn"
        }
    }
}


