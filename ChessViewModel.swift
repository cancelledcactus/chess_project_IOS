import Foundation

final class ChessViewModel: ObservableObject {
    @Published var game = GameState()
    private var previousStates: [GameState] = []

    var selectedPosition: Position? {
        game.selectedPosition
    }

    var canUndo: Bool {
        !previousStates.isEmpty
    }

    var statusText: String {
        if let winner = game.winner {
            return "Checkmate — \(winner.displayName) wins"
        }
        if game.isStalemate {
            return "Stalemate — draw"
        }
        if game.isCheck {
            return "\(game.currentTurn.displayName) is in check"
        }
        return "\(game.currentTurn.displayName)'s turn"
    }

    func tapSquare(_ position: Position) {
        guard game.winner == nil, !game.isStalemate else { return }

        if let selected = game.selectedPosition {
            if selected == position {
                clearSelection()
                return
            }

            if let move = ChessEngine.legalMoves(for: selected, in: game).first(where: { $0.to == position }) {
                previousStates.append(game)
                ChessEngine.apply(move: move, to: &game)
                return
            }

            if let piece = game.piece(at: position), piece.color == game.currentTurn {
                select(position)
            } else {
                clearSelection()
            }
        } else if let piece = game.piece(at: position), piece.color == game.currentTurn {
            select(position)
        }
    }

    func resetGame() {
        game = GameState()
        previousStates.removeAll()
    }

    func undoLastMove() {
        guard let previous = previousStates.popLast() else { return }
        game = previous
    }

    func isSelected(_ position: Position) -> Bool {
        game.selectedPosition == position
    }

    func isLegalTarget(_ position: Position) -> Bool {
        game.legalMovesForSelection.contains(position)
    }

    func piece(at position: Position) -> Piece? {
        game.piece(at: position)
    }

    private func select(_ position: Position) {
        game.selectedPosition = position
        game.legalMovesForSelection = ChessEngine.legalMoves(for: position, in: game).map { $0.to }
    }

    private func clearSelection() {
        game.selectedPosition = nil
        game.legalMovesForSelection = []
    }
}
