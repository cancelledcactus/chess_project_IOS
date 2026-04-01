import SwiftUI

struct SquareView: View {
    let position: Position
    let piece: Piece?
    let isSelected: Bool
    let isLegalTarget: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(baseColor)

                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.blue.opacity(0.85), lineWidth: 4)
                        .padding(3)
                } else if isLegalTarget {
                    Circle()
                        .fill(Color.green.opacity(piece == nil ? 0.35 : 0.18))
                        .frame(width: piece == nil ? 18 : 52, height: piece == nil ? 18 : 52)
                        .overlay {
                            if piece != nil {
                                Circle()
                                    .stroke(Color.green.opacity(0.65), lineWidth: 4)
                                    .frame(width: 54, height: 54)
                            }
                        }
                }

                if let piece {
                    Text(piece.symbol)
                        .font(.system(size: 34))
                }

                VStack {
                    HStack {
                        if position.col == 0 {
                            Text("\(8 - position.row)")
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(labelColor)
                                .padding(4)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if position.row == 7 {
                            Text(["a","b","c","d","e","f","g","h"][position.col])
                                .font(.caption2)
                                .fontWeight(.bold)
                                .foregroundStyle(labelColor)
                                .padding(4)
                        }
                    }
                }
            }
            .aspectRatio(1, contentMode: .fit)
        }
        .buttonStyle(.plain)
    }

    private var isLightSquare: Bool {
        (position.row + position.col).isMultiple(of: 2)
    }

    private var baseColor: Color {
        isLightSquare ? Color(red: 0.94, green: 0.90, blue: 0.83) : Color(red: 0.57, green: 0.41, blue: 0.30)
    }

    private var labelColor: Color {
        isLightSquare ? .black.opacity(0.65) : .white.opacity(0.75)
    }
}

#Preview {
    SquareView(
        position: Position(row: 6, col: 4),
        piece: Piece(type: .pawn, color: .white),
        isSelected: true,
        isLegalTarget: false,
        action: {}
    )
    .padding()
}
