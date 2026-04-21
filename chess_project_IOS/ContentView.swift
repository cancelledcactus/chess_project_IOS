import SwiftUI

struct ContentView: View {
    @StateObject private var viewModel = ChessViewModel()

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                header

                BoardView(viewModel: viewModel)
                    .padding(.horizontal)

                footer
            }
            .padding(.vertical)
            .navigationTitle("Swift Chess")
        }
    }

    private var header: some View {
        VStack(spacing: 8) {
            Text(viewModel.statusText)
                .font(.headline)
                .multilineTextAlignment(.center)

            HStack(spacing: 12) {
                Text("Turn: \(viewModel.game.currentTurn.displayName)")
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(.thinMaterial)
                    .clipShape(Capsule())

                if let lastMove = viewModel.game.lastMove {
                    Text("Last move: \(lastMove.algebraicDescription)")
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(.thinMaterial)
                        .clipShape(Capsule())
                }
            }
        }
        .padding(.horizontal)
    }

    private var footer: some View {
        VStack(spacing: 12) {
            if let selected = viewModel.selectedPosition {
                Text("Selected: \(selected.algebraic)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            HStack(spacing: 12) {
                Button("Reset Game") {
                    viewModel.resetGame()
                }
                .buttonStyle(.borderedProminent)

                Button("Undo Move") {
                    viewModel.undoLastMove()
                }
                .buttonStyle(.bordered)
                .disabled(!viewModel.canUndo)
            }
        }
    }
}

