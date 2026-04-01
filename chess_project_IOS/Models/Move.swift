import Foundation

struct Move: Equatable, Codable {
    let from: Position
    let to: Position
    let piece: Piece
    let capturedPiece: Piece?
    let promotion: PieceType?
    let isCastleKingSide: Bool
    let isCastleQueenSide: Bool
    let isEnPassant: Bool

    var algebraicDescription: String {
        if isCastleKingSide { return "O-O" }
        if isCastleQueenSide { return "O-O-O" }

        let piecePrefix: String
        switch piece.type {
        case .king: piecePrefix = "K"
        case .queen: piecePrefix = "Q"
        case .rook: piecePrefix = "R"
        case .bishop: piecePrefix = "B"
        case .knight: piecePrefix = "N"
        case .pawn: piecePrefix = ""
        }

        let captureMarker = capturedPiece != nil || isEnPassant ? "x" : "-"
        let promotionText = promotion.map { "=\($0.rawValue.prefix(1).uppercased())" } ?? ""
        return "\(piecePrefix)\(from.algebraic)\(captureMarker)\(to.algebraic)\(promotionText)"
    }
}
