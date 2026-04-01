import SwiftUI

struct SquareView: View {
    let piece: Piece?
    let position: Position
    let isSelected: Bool
    let isLegalTarget: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            ZStack {
                Rectangle()
                    .fill(squareColor)

                if isSelected {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.yellow, lineWidth: 4)
                        .padding(3)
                }

                if isLegalTarget {
                    Circle()
                        .fill(Color.blue.opacity(0.35))
                        .frame(width: 18, height: 18)
                }

                if let piece {
                    Text(piece.symbol)
                        .font(.system(size: 32))
                }

                VStack {
                    HStack {
                        if position.row == 7 {
                            Text(String(UnicodeScalar(97 + position.col)!))
                                .font(.caption2)
                                .foregroundStyle(.primary.opacity(0.65))
                                .padding(4)
                        }
                        Spacer()
                    }
                    Spacer()
                    HStack {
                        Spacer()
                        if position.col == 0 {
                            Text("\(8 - position.row)")
                                .font(.caption2)
                                .foregroundStyle(.primary.opacity(0.65))
                                .padding(4)
                        }
                    }
                }
            }
        }
        .buttonStyle(.plain)
    }

    private var squareColor: Color {
        let isDark = (position.row + position.col).isMultiple(of: 2) == false
        return isDark ? Color(red: 0.72, green: 0.54, blue: 0.39) : Color(red: 0.95, green: 0.88, blue: 0.78)
    }
}
