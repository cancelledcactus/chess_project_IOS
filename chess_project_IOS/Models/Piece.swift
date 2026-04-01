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

struct Piece: Identifiable, Equatable, Codable {
    let id: UUID
    let color: PieceColor
    let type: PieceType
    var hasMoved: Bool

    init(id: UUID = UUID(), color: PieceColor, type: PieceType, hasMoved: Bool = false) {
        self.id = id
        self.color = color
        self.type = type
        self.hasMoved = hasMoved
    }

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
        case (.black, .pawn): return "♟︎"
        }
    }
}
