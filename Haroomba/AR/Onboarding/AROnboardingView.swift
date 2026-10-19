import SwiftUI
import RealityKit
import ARKit

enum OnboardingState {
    case scanningFloor
    case planeFound(canPlace: Bool)
    case placed
}

struct AROnboardingOverlay: View {
    let state: OnboardingState

    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            switch state {
            case .scanningFloor:
                scanningContent
            case .planeFound(let canPlace):
                planeFoundContent(canPlace: canPlace)
            case .placed:
                EmptyView()
            }
            Spacer()
        }
    }

    private var scanningContent: some View {
        VStack(spacing: 12) {
            Image(systemName: "iphone.and.arrow.forward")
                .font(.system(size: 48))
                .foregroundStyle(.white)
                .symbolEffect(.bounce, options: .repeating)
            Text("Направьте камеру на пол")
                .font(.headline)
                .foregroundStyle(.white)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func planeFoundContent(canPlace: Bool) -> some View {
        VStack(spacing: 12) {
            Image(systemName: canPlace ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                .font(.system(size: 36))
                .foregroundStyle(canPlace ? .green : .red)
            Text(canPlace ? "Нажмите чтобы разместить колодец" : "Найдите более подходящее место")
                .font(.headline)
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)
                .padding(.vertical, 10)
                .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }
}

// The screen ring drawn on-screen before a plane is found
struct ScreenRingView: View {
    var color: Color = .white.opacity(0.7)
    var diameter: CGFloat = 160

    var body: some View {
        Circle()
            .strokeBorder(color, lineWidth: 3)
            .frame(width: diameter, height: diameter)
            .shadow(color: color, radius: 6)
    }
}
