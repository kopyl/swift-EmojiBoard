import SwiftUI


struct AnimationProperties {
    var rotationAngle = 0.0
}

struct ShakingModifier: ViewModifier {
    @Binding var isRemoving: Bool
    var canBeRemoved: Bool
    
    let angle: Angle = .zero

    func body(content: Content) -> some View {
        content
            .keyframeAnimator(
                initialValue: AnimationProperties(),
                repeating: isRemoving && canBeRemoved
            ) {
                content, value in
                content
                    .rotationEffect(Angle(degrees: isRemoving ? value.rotationAngle : 0))
            } keyframes: {_ in
                KeyframeTrack(\.rotationAngle) {
                    CubicKeyframe(10, duration: 0.1)
                    CubicKeyframe(-10, duration: 0.1)
                    CubicKeyframe(5, duration: 0.1)
                    CubicKeyframe(-5, duration: 0.1)
                    CubicKeyframe(0, duration: 0.1)
                }
                
            }
            .rotationEffect(isRemoving ? angle : .zero)
            .animation(.easeInOut(duration: 0.1), value: isRemoving)
    }
}

extension View {
    func shaking(_ isRemoving: Binding<Bool>, _ canBeRemoved: Bool) -> some View {
        self.modifier(ShakingModifier(isRemoving: isRemoving, canBeRemoved: canBeRemoved))
    }
}
