import Foundation

enum ChessEngine {
    static func legalMoves(for position: Position, in game: GameState) -> [Move] {
        guard let piece = game.piece(at: position), piece.color == game.currentTurn else { return [] }

        let pseudoMoves = pseudoLegalMoves(for: position, board: game.board)

        return pseudoMoves.filter { move in
            var nextGame = game
            apply(move: move, to: &nextGame, evaluateOutcome: false)
            return !isKingInCheck(color: piece.color, board: nextGame.board)
        }
    }

    static func apply(move: Move, to game: inout GameState, evaluateOutcome: Bool = true) {
        game.setPiece(nil, at: move.from)

        let placedPiece: Piece
        if let promotion = move.promotion {
            placedPiece = Piece(type: promotion, color: move.movedPiece.color)
        } else {
            placedPiece = move.movedPiece
        }

        game.setPiece(placedPiece, at: move.to)
        game.lastMove = move
        game.selectedPosition = nil
        game.legalMovesForSelection = []
        game.currentTurn = game.currentTurn.opposite

        guard evaluateOutcome else { return }

        let nextTurn = game.currentTurn
        game.isCheck = isKingInCheck(color: nextTurn, board: game.board)

        let hasLegalMove = allLegalMoves(for: nextTurn, in: game).isEmpty == false
        if !hasLegalMove {
            if game.isCheck {
                game.winner = nextTurn.opposite
                game.isStalemate = false
            } else {
                game.winner = nil
                game.isStalemate = true
            }
        } else {
            game.winner = nil
            game.isStalemate = false
        }
    }

    static func allLegalMoves(for color: PieceColor, in game: GameState) -> [Move] {
        var adjusted = game
        adjusted.currentTurn = color
        var result: [Move] = []

        for row in 0..<8 {
            for col in 0..<8 {
                let position = Position(row: row, col: col)
                if adjusted.piece(at: position)?.color == color {
                    result.append(contentsOf: legalMoves(for: position, in: adjusted))
                }
            }
        }
        return result
    }

    static func isKingInCheck(color: PieceColor, board: [[Piece?]]) -> Bool {
        guard let kingPosition = kingPosition(for: color, board: board) else { return false }
        return isSquareAttacked(kingPosition, by: color.opposite, board: board)
    }

    private static func kingPosition(for color: PieceColor, board: [[Piece?]]) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                if let piece = board[row][col], piece.type == .king, piece.color == color {
                    return Position(row: row, col: col)
                }
            }
        }
        return nil
    }

    private static func isSquareAttacked(_ target: Position, by attacker: PieceColor, board: [[Piece?]]) -> Bool {
        for row in 0..<8 {
            for col in 0..<8 {
                let from = Position(row: row, col: col)
                guard let piece = board[row][col], piece.color == attacker else { continue }
                let moves = pseudoLegalMoves(for: from, board: board, attackOnly: true)
                if moves.contains(where: { $0.to == target }) {
                    return true
                }
            }
        }
        return false
    }

    private static func pseudoLegalMoves(for position: Position, board: [[Piece?]], attackOnly: Bool = false) -> [Move] {
        guard let piece = board[position.row][position.col] else { return [] }

        switch piece.type {
        case .pawn:
            return pawnMoves(from: position, piece: piece, board: board, attackOnly: attackOnly)
        case .rook:
            return slidingMoves(from: position, piece: piece, board: board, directions: [(1,0),(-1,0),(0,1),(0,-1)])
        case .bishop:
            return slidingMoves(from: position, piece: piece, board: board, directions: [(1,1),(1,-1),(-1,1),(-1,-1)])
        case .queen:
            return slidingMoves(from: position, piece: piece, board: board, directions: [(1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)])
        case .knight:
            return knightMoves(from: position, piece: piece, board: board)
        case .king:
            return kingMoves(from: position, piece: piece, board: board)
        }
    }

    private static func pawnMoves(from position: Position, piece: Piece, board: [[Piece?]], attackOnly: Bool) -> [Move] {
        var moves: [Move] = []
        let direction = piece.color == .white ? -1 : 1
        let startRow = piece.color == .white ? 6 : 1
        let promotionRow = piece.color == .white ? 0 : 7

        for dc in [-1, 1] {
            let target = Position(row: position.row + direction, col: position.col + dc)
            guard target.isValid else { continue }
            if let captured = board[target.row][target.col], captured.color != piece.color {
                moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: captured, promotion: target.row == promotionRow ? .queen : nil))
            } else if attackOnly {
                moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: nil, promotion: nil))
            }
        }

        guard !attackOnly else { return moves }

        let oneStep = Position(row: position.row + direction, col: position.col)
        if oneStep.isValid, board[oneStep.row][oneStep.col] == nil {
            moves.append(Move(from: position, to: oneStep, movedPiece: piece, capturedPiece: nil, promotion: oneStep.row == promotionRow ? .queen : nil))

            let twoStep = Position(row: position.row + (2 * direction), col: position.col)
            if position.row == startRow, twoStep.isValid, board[twoStep.row][twoStep.col] == nil {
                moves.append(Move(from: position, to: twoStep, movedPiece: piece, capturedPiece: nil, promotion: nil))
            }
        }

        return moves
    }

    private static func slidingMoves(from position: Position, piece: Piece, board: [[Piece?]], directions: [(Int, Int)]) -> [Move] {
        var moves: [Move] = []

        for (dr, dc) in directions {
            var row = position.row + dr
            var col = position.col + dc

            while Position(row: row, col: col).isValid {
                let target = Position(row: row, col: col)
                if let occupant = board[row][col] {
                    if occupant.color != piece.color {
                        moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: occupant, promotion: nil))
                    }
                    break
                } else {
                    moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: nil, promotion: nil))
                }
                row += dr
                col += dc
            }
        }

        return moves
    }

    private static func knightMoves(from position: Position, piece: Piece, board: [[Piece?]]) -> [Move] {
        let jumps = [(2,1),(2,-1),(-2,1),(-2,-1),(1,2),(1,-2),(-1,2),(-1,-2)]

        return jumps.compactMap { dr, dc in
            let target = Position(row: position.row + dr, col: position.col + dc)
            guard target.isValid else { return nil }
            if let occupant = board[target.row][target.col] {
                guard occupant.color != piece.color else { return nil }
                return Move(from: position, to: target, movedPiece: piece, capturedPiece: occupant, promotion: nil)
            }
            return Move(from: position, to: target, movedPiece: piece, capturedPiece: nil, promotion: nil)
        }
    }

    private static func kingMoves(from position: Position, piece: Piece, board: [[Piece?]]) -> [Move] {
        let deltas = [-1, 0, 1]
        var moves: [Move] = []

        for dr in deltas {
            for dc in deltas where !(dr == 0 && dc == 0) {
                let target = Position(row: position.row + dr, col: position.col + dc)
                guard target.isValid else { continue }
                if let occupant = board[target.row][target.col] {
                    if occupant.color != piece.color {
                        moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: occupant, promotion: nil))
                    }
                } else {
                    moves.append(Move(from: position, to: target, movedPiece: piece, capturedPiece: nil, promotion: nil))
                }
            }
        }

        return moves
    }
}
