import SwiftUI

struct BoardView: View {
    @ObservedObject var viewModel: ChessViewModel

    var body: some View {
        GeometryReader { geo in
            let size = min(geo.size.width, geo.size.height)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 8), spacing: 0) {
                ForEach(0..<8, id: \.self) { row in
                    ForEach(0..<8, id: \.self) { col in
                        let position = Position(row: row, col: col)
                        SquareView(
                            position: position,
                            piece: viewModel.piece(at: position),
                            isSelected: viewModel.isSelected(position),
                            isLegalTarget: viewModel.isLegalTarget(position)
                        ) {
                            viewModel.tapSquare(position)
                        }
                    }
                }
            }
            .frame(width: size, height: size)
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay {
                RoundedRectangle(cornerRadius: 14)
                    .stroke(Color.primary.opacity(0.15), lineWidth: 1)
            }
            .shadow(radius: 8)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

#Preview {
    BoardView(viewModel: ChessViewModel())
        .padding()
}
