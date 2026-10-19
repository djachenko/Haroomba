import SwiftUI
import Tetris

struct GameHUDView: View {
    let score: Int
    let nextBrick: BrickIcon?
    let onRotate: () -> Void

    var body: some View {
        VStack {
            HStack(alignment: .top) {
                scoreView
                Spacer()
                if let next = nextBrick {
                    NextBrickView(icon: next)
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 60)

            Spacer()

            HStack {
                Spacer()
                rotateButton
                    .padding(.trailing, 28)
                    .padding(.bottom, 48)
            }
        }
    }

    private var scoreView: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("СЧЁТ")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            Text("\(score)")
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(.white)
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var rotateButton: some View {
        Button(action: onRotate) {
            Image(systemName: "arrow.trianglehead.2.clockwise.rotate.90")
                .font(.system(size: 28, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 64, height: 64)
                .background(.ultraThinMaterial, in: Circle())
        }
    }
}

struct BrickIcon {
    let colorIndex: Int
    let points: [(Int, Int)]
}

struct NextBrickView: View {
    let icon: BrickIcon

    var body: some View {
        VStack(alignment: .trailing, spacing: 2) {
            Text("ДАЛЕЕ")
                .font(.caption)
                .foregroundStyle(.white.opacity(0.7))
            brickPreview
        }
        .padding(12)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
    }

    private var brickPreview: some View {
        let colors: [Color] = [.cyan, .blue, .orange, .yellow, .green, .purple, .red]
        let c = colors[icon.colorIndex % colors.count]
        return Canvas { ctx, size in
            let cellSize: CGFloat = 10
            for (x, y) in icon.points {
                let rect = CGRect(x: CGFloat(x) * cellSize + 4, y: CGFloat(y) * cellSize + 4,
                                  width: cellSize - 1, height: cellSize - 1)
                ctx.fill(Path(roundedRect: rect, cornerRadius: 2), with: .color(c))
            }
        }
        .frame(width: 50, height: 30)
    }
}

struct PauseOverlayView: View {
    var body: some View {
        VStack(spacing: 16) {
            Text("⏸")
                .font(.system(size: 64))
            Text("Войдите в колодец")
                .font(.title2.bold())
                .foregroundStyle(.white)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.35))
    }
}
