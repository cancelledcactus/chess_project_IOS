import Foundation

struct GameState: Codable {
    var board: [[Piece?]]
    var currentTurn: PieceColor
    var selectedPosition: Position?
    var legalMovesForSelection: [Position]
    var winner: PieceColor?
    var isStalemate: Bool
    var isCheck: Bool
    var moveHistory: [Move]
    var capturedWhite: [Piece]
    var capturedBlack: [Piece]
    var enPassantTarget: Position?
    var lastMove: Move?

    init() {
        self.board = Self.initialBoard()
        self.currentTurn = .white
        self.selectedPosition = nil
        self.legalMovesForSelection = []
        self.winner = nil
        self.isStalemate = false
        self.isCheck = false
        self.moveHistory = []
        self.capturedWhite = []
        self.capturedBlack = []
        self.enPassantTarget = nil
        self.lastMove = nil
    }

    static func initialBoard() -> [[Piece?]] {
        var board = Array(repeating: Array(repeating: Optional<Piece>.none, count: 8), count: 8)
        let backRow: [PieceType] = [.rook, .knight, .bishop, .queen, .king, .bishop, .knight, .rook]

        for col in 0..<8 {
            board[0][col] = Piece(color: .black, type: backRow[col])
            board[1][col] = Piece(color: .black, type: .pawn)
            board[6][col] = Piece(color: .white, type: .pawn)
            board[7][col] = Piece(color: .white, type: backRow[col])
        }

        return board
    }

    func piece(at position: Position) -> Piece? {
        guard position.isValid else { return nil }
        return board[position.row][position.col]
    }
}
