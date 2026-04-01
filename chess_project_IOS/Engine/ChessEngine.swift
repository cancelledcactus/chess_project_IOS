import Foundation

enum ChessEngine {
    static func legalMoves(for position: Position, in game: GameState) -> [Move] {
        guard let piece = game.piece(at: position), piece.color == game.currentTurn else {
            return []
        }

        let pseudoMoves = pseudoLegalMoves(for: position, in: game)
        return pseudoMoves.filter { move in
            !wouldLeaveKingInCheck(move: move, in: game)
        }
    }

    static func allLegalMoves(for color: PieceColor, in game: GameState) -> [Move] {
        var copy = game
        copy.currentTurn = color

        var result: [Move] = []
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = copy.piece(at: pos), piece.color == color {
                    result.append(contentsOf: legalMoves(for: pos, in: copy))
                }
            }
        }
        return result
    }

    static func isKingInCheck(color: PieceColor, in game: GameState) -> Bool {
        guard let kingPosition = findKing(color: color, in: game) else { return false }

        let enemyColor = color.opposite
        var enemyTurnGame = game
        enemyTurnGame.currentTurn = enemyColor

        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                guard let piece = enemyTurnGame.piece(at: pos), piece.color == enemyColor else { continue }
                let attacks = pseudoLegalMoves(for: pos, in: enemyTurnGame, includeCastling: false)
                if attacks.contains(where: { $0.to == kingPosition }) {
                    return true
                }
            }
        }

        return false
    }

    static func apply(move: Move, to game: inout GameState) {
        var movingPiece = move.piece
        movingPiece.hasMoved = true

        game.board[move.from.row][move.from.col] = nil

        if move.isEnPassant {
            let capturedRow = move.piece.color == .white ? move.to.row + 1 : move.to.row - 1
            if let captured = game.board[capturedRow][move.to.col] {
                capture(piece: captured, in: &game)
            }
            game.board[capturedRow][move.to.col] = nil
        } else if let captured = move.capturedPiece {
            capture(piece: captured, in: &game)
        }

        if move.isCastleKingSide {
            game.board[move.to.row][move.to.col] = movingPiece
            if var rook = game.board[move.to.row][7] {
                rook.hasMoved = true
                game.board[move.to.row][7] = nil
                game.board[move.to.row][5] = rook
            }
        } else if move.isCastleQueenSide {
            game.board[move.to.row][move.to.col] = movingPiece
            if var rook = game.board[move.to.row][0] {
                rook.hasMoved = true
                game.board[move.to.row][0] = nil
                game.board[move.to.row][3] = rook
            }
        } else {
            if let promotionType = move.promotion {
                game.board[move.to.row][move.to.col] = Piece(color: movingPiece.color, type: promotionType, hasMoved: true)
            } else {
                game.board[move.to.row][move.to.col] = movingPiece
            }
        }

        game.enPassantTarget = nil
        if move.piece.type == .pawn, abs(move.from.row - move.to.row) == 2 {
            let middleRow = (move.from.row + move.to.row) / 2
            game.enPassantTarget = Position(row: middleRow, col: move.from.col)
        }

        game.moveHistory.append(move)
        game.lastMove = move
        game.selectedPosition = nil
        game.legalMovesForSelection = []
        game.currentTurn = game.currentTurn.opposite

        let nextColor = game.currentTurn
        let nextMoves = allLegalMoves(for: nextColor, in: game)
        let inCheck = isKingInCheck(color: nextColor, in: game)

        game.isCheck = inCheck
        if nextMoves.isEmpty {
            if inCheck {
                game.winner = nextColor.opposite
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

    static func pseudoLegalMoves(for position: Position, in game: GameState, includeCastling: Bool = true) -> [Move] {
        guard let piece = game.piece(at: position) else { return [] }

        switch piece.type {
        case .pawn:
            return pawnMoves(from: position, piece: piece, in: game)
        case .rook:
            return slidingMoves(from: position, piece: piece, in: game, directions: [(1,0),(-1,0),(0,1),(0,-1)])
        case .bishop:
            return slidingMoves(from: position, piece: piece, in: game, directions: [(1,1),(1,-1),(-1,1),(-1,-1)])
        case .queen:
            return slidingMoves(from: position, piece: piece, in: game, directions: [(1,0),(-1,0),(0,1),(0,-1),(1,1),(1,-1),(-1,1),(-1,-1)])
        case .knight:
            return knightMoves(from: position, piece: piece, in: game)
        case .king:
            return kingMoves(from: position, piece: piece, in: game, includeCastling: includeCastling)
        }
    }

    static func wouldLeaveKingInCheck(move: Move, in game: GameState) -> Bool {
        var copy = game
        apply(move: move, to: &copy)
        copy.currentTurn = move.piece.color
        return isKingInCheck(color: move.piece.color, in: copy)
    }

    static func findKing(color: PieceColor, in game: GameState) -> Position? {
        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                if let piece = game.piece(at: pos), piece.color == color, piece.type == .king {
                    return pos
                }
            }
        }
        return nil
    }

    private static func capture(piece: Piece, in game: inout GameState) {
        if piece.color == .white {
            game.capturedWhite.append(piece)
        } else {
            game.capturedBlack.append(piece)
        }
    }

    private static func pawnMoves(from position: Position, piece: Piece, in game: GameState) -> [Move] {
        var moves: [Move] = []
        let direction = piece.color == .white ? -1 : 1
        let startRow = piece.color == .white ? 6 : 1
        let promotionRow = piece.color == .white ? 0 : 7

        let oneForward = Position(row: position.row + direction, col: position.col)
        if oneForward.isValid, game.piece(at: oneForward) == nil {
            if oneForward.row == promotionRow {
                for promo in [PieceType.queen, .rook, .bishop, .knight] {
                    moves.append(Move(from: position, to: oneForward, piece: piece, capturedPiece: nil, promotion: promo, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                }
            } else {
                moves.append(Move(from: position, to: oneForward, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
            }

            let twoForward = Position(row: position.row + (2 * direction), col: position.col)
            if position.row == startRow, twoForward.isValid, game.piece(at: twoForward) == nil {
                moves.append(Move(from: position, to: twoForward, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
            }
        }

        for dc in [-1, 1] {
            let diagonal = Position(row: position.row + direction, col: position.col + dc)
            guard diagonal.isValid else { continue }

            if let target = game.piece(at: diagonal), target.color != piece.color {
                if diagonal.row == promotionRow {
                    for promo in [PieceType.queen, .rook, .bishop, .knight] {
                        moves.append(Move(from: position, to: diagonal, piece: piece, capturedPiece: target, promotion: promo, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                    }
                } else {
                    moves.append(Move(from: position, to: diagonal, piece: piece, capturedPiece: target, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                }
            }

            if let enPassant = game.enPassantTarget, enPassant == diagonal {
                let capturedPos = Position(row: position.row, col: diagonal.col)
                if let captured = game.piece(at: capturedPos), captured.color != piece.color, captured.type == .pawn {
                    moves.append(Move(from: position, to: diagonal, piece: piece, capturedPiece: captured, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: true))
                }
            }
        }

        return moves
    }

    private static func slidingMoves(from position: Position, piece: Piece, in game: GameState, directions: [(Int, Int)]) -> [Move] {
        var moves: [Move] = []

        for (dr, dc) in directions {
            var row = position.row + dr
            var col = position.col + dc

            while Position(row: row, col: col).isValid {
                let target = Position(row: row, col: col)
                if let occupying = game.piece(at: target) {
                    if occupying.color != piece.color {
                        moves.append(Move(from: position, to: target, piece: piece, capturedPiece: occupying, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                    }
                    break
                } else {
                    moves.append(Move(from: position, to: target, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                }

                row += dr
                col += dc
            }
        }

        return moves
    }

    private static func knightMoves(from position: Position, piece: Piece, in game: GameState) -> [Move] {
        let offsets = [
            (-2, -1), (-2, 1),
            (-1, -2), (-1, 2),
            (1, -2), (1, 2),
            (2, -1), (2, 1)
        ]

        return offsets.compactMap { dr, dc in
            let target = Position(row: position.row + dr, col: position.col + dc)
            guard target.isValid else { return nil }

            if let occupying = game.piece(at: target) {
                guard occupying.color != piece.color else { return nil }
                return Move(from: position, to: target, piece: piece, capturedPiece: occupying, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false)
            }

            return Move(from: position, to: target, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false)
        }
    }

    private static func kingMoves(from position: Position, piece: Piece, in game: GameState, includeCastling: Bool) -> [Move] {
        var moves: [Move] = []

        for dr in -1...1 {
            for dc in -1...1 {
                if dr == 0 && dc == 0 { continue }
                let target = Position(row: position.row + dr, col: position.col + dc)
                guard target.isValid else { continue }

                if let occupying = game.piece(at: target) {
                    guard occupying.color != piece.color else { continue }
                    moves.append(Move(from: position, to: target, piece: piece, capturedPiece: occupying, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                } else {
                    moves.append(Move(from: position, to: target, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: false, isEnPassant: false))
                }
            }
        }

        guard includeCastling, !piece.hasMoved, !isKingInCheck(color: piece.color, in: game) else {
            return moves
        }

        let row = position.row

        if let rook = game.board[row][7], rook.type == .rook, rook.color == piece.color, !rook.hasMoved,
           game.board[row][5] == nil, game.board[row][6] == nil {
            let pass1 = Position(row: row, col: 5)
            let pass2 = Position(row: row, col: 6)

            if !squareIsAttacked(pass1, by: piece.color.opposite, in: game),
               !squareIsAttacked(pass2, by: piece.color.opposite, in: game) {
                moves.append(Move(from: position, to: pass2, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: true, isCastleQueenSide: false, isEnPassant: false))
            }
        }

        if let rook = game.board[row][0], rook.type == .rook, rook.color == piece.color, !rook.hasMoved,
           game.board[row][1] == nil, game.board[row][2] == nil, game.board[row][3] == nil {
            let pass1 = Position(row: row, col: 3)
            let pass2 = Position(row: row, col: 2)

            if !squareIsAttacked(pass1, by: piece.color.opposite, in: game),
               !squareIsAttacked(pass2, by: piece.color.opposite, in: game) {
                moves.append(Move(from: position, to: pass2, piece: piece, capturedPiece: nil, promotion: nil, isCastleKingSide: false, isCastleQueenSide: true, isEnPassant: false))
            }
        }

        return moves
    }

    private static func squareIsAttacked(_ square: Position, by color: PieceColor, in game: GameState) -> Bool {
        var copy = game
        copy.currentTurn = color

        for row in 0..<8 {
            for col in 0..<8 {
                let pos = Position(row: row, col: col)
                guard let piece = copy.piece(at: pos), piece.color == color else { continue }
                let attacks = pseudoLegalMoves(for: pos, in: copy, includeCastling: false)
                if attacks.contains(where: { $0.to == square }) {
                    return true
                }
            }
        }
        return false
    }
}
