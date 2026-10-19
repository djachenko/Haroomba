import SwiftUI

struct TutorialOverlayView: View {
    let onDismiss: () -> Void

    @State private var step = 0

    private let steps: [(icon: String, text: String)] = [
        ("arrow.left.arrow.right", "Поворачивайтесь чтобы двигать блок"),
        ("rotate.right", "Нажмите на экран или кнопку ↻ чтобы повернуть блок"),
        ("arrow.down.to.line", "Свайп вниз — быстрый сброс"),
        ("figure.walk.departure", "Выйдите из колодца чтобы поставить на паузу"),
    ]

    var body: some View {
        VStack {
            Spacer()
            if step < steps.count {
                let s = steps[step]
                VStack(spacing: 16) {
                    Image(systemName: s.icon)
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                        .symbolEffect(.bounce)
                    Text(s.text)
                        .font(.title3.bold())
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                    Button(step < steps.count - 1 ? "Далее" : "Начать") {
                        if step < steps.count - 1 {
                            step += 1
                        } else {
                            onDismiss()
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
                .padding(28)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 20))
                .padding(.horizontal, 32)
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
            Spacer().frame(height: 80)
        }
        .animation(.spring, value: step)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black.opacity(0.4))
    }
}
