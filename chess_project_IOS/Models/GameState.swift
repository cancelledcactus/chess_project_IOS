import Foundation

struct GameState: Equatable {
    var board: [[Piece?]]
    var currentTurn: PieceColor
    var selectedPosition: Position?
    var legalMovesForSelection: [Position]
    var lastMove: Move?
    var winner: PieceColor?
    var isCheck: Bool
    var isStalemate: Bool

    init(
        board: [[Piece?]] = GameState.makeInitialBoard(),
        currentTurn: PieceColor = .white,
        selectedPosition: Position? = nil,
        legalMovesForSelection: [Position] = [],
        lastMove: Move? = nil,
        winner: PieceColor? = nil,
        isCheck: Bool = false,
        isStalemate: Bool = false
    ) {
        self.board = board
        self.currentTurn = currentTurn
        self.selectedPosition = selectedPosition
        self.legalMovesForSelection = legalMovesForSelection
        self.lastMove = lastMove
        self.winner = winner
        self.isCheck = isCheck
        self.isStalemate = isStalemate
    }

    func piece(at position: Position) -> Piece? {
        guard position.isValid else { return nil }
        return board[position.row][position.col]
    }

    mutating func setPiece(_ piece: Piece?, at position: Position) {
        guard position.isValid else { return }
        board[position.row][position.col] = piece
    }

    static func makeInitialBoard() -> [[Piece?]] {
        var board = Array(repeating: Array(repeating: Optional<Piece>.none, count: 8), count: 8)

        let backRank: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]

        for col in 0..<8 {
            board[0][col] = Piece(type: backRank[col], color: .black)
            board[1][col] = Piece(type: .pawn, color: .black)
            board[6][col] = Piece(type: .pawn, color: .white)
            board[7][col] = Piece(type: backRank[col], color: .white)
        }

        return board
    }
}
