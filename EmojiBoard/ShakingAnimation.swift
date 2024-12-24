import SwiftUI


struct AnimationProperties {
    var rotationAngle = 0.0
}

struct ShakingModifier: ViewModifier {
    @Binding var isRemoving: Bool
    @State private var angle: Angle = .zero

    let totalDuration = 0.7

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(
                initialValue: AnimationProperties(),
                repeating: isRemoving
            ) {
                content, value in
                content
                    .rotationEffect(Angle(degrees: isRemoving ? value.rotationAngle : 0))
            } keyframes: {_ in
                KeyframeTrack(\.rotationAngle) {
                    SpringKeyframe(-30, duration: totalDuration * 0.15)
                    SpringKeyframe(30, duration: totalDuration * 0.15)
                    SpringKeyframe(-30, duration: totalDuration * 0.15)
                    SpringKeyframe(0, duration: totalDuration * 0.15)
                }
                
            }
            .rotationEffect(isRemoving ? angle : .zero)
            .animation(.easeInOut(duration: 0.1), value: isRemoving)
    }
}

extension View {
    func shaking(_ isRemoving: Binding<Bool>) -> some View {
        self.modifier(ShakingModifier(isRemoving: isRemoving))
    }
}
