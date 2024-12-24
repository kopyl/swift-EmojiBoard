import SwiftUI


struct AnimationProperties {
    var rotationAngle = 0.0
}

struct ShakingModifier: ViewModifier {
    @Binding var isRemoving: Bool
    var canBeRemoved: Bool
    
    let angle: Angle = .zero
    let totalDuration = 0.05

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
                    SpringKeyframe(0, duration: totalDuration * 0.25)
                    SpringKeyframe(-80, duration: totalDuration * 0.50)
                    SpringKeyframe(0, duration: totalDuration * 0.75)
                    SpringKeyframe(80, duration: totalDuration * 1)
                    SpringKeyframe(0, duration: totalDuration * 1)
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
