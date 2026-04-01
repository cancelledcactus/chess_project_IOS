import Foundation

struct Move: Equatable, Codable, Hashable {
    let from: Position
    let to: Position
    let movedPiece: Piece
    let capturedPiece: Piece?
    let promotion: PieceType?

    var algebraicDescription: String {
        if let promotion {
            return "\(from.algebraic)→\(to.algebraic)=\(promotion.rawValue.capitalized)"
        }
        return "\(from.algebraic)→\(to.algebraic)"
    }
}
