import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: ChessViewModel

    var body: some View {
        GeometryReader { geometry in
            let boardSize = min(geometry.size.width, geometry.size.height)
            let squareSize = boardSize / 8

            VStack(spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    HStack(spacing: 0) {
                        ForEach(0..<8, id: \.self) { col in
                            let position = Position(row: row, col: col)
                            SquareView(
                                piece: viewModel.piece(at: position),
                                position: position,
                                isSelected: viewModel.isSelected(position),
                                isLegalTarget: viewModel.isLegalTarget(position),
                                action: {
                                    viewModel.tapSquare(position)
                                }
                            )
                            .frame(width: squareSize, height: squareSize)
                        }
                    }
                }
            }
            .frame(width: boardSize, height: boardSize)
            .background(.black.opacity(0.15))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.secondary.opacity(0.3), lineWidth: 1)
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}
