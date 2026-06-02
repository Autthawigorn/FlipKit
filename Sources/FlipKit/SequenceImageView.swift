import SwiftUI

// MARK: - SequenceImageView
/// A View component that renders the animation sequence managed by AnimationManager
public struct SequenceImageView: View {
    @ObservedObject public var manager: AnimationManager
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    public var width: CGFloat? = nil
    public var height: CGFloat? = nil
    public var contentMode: ContentMode = .fit
    public var accessibilityLabel: String? = nil

    public init(
        manager: AnimationManager,
        width: CGFloat? = nil,
        height: CGFloat? = nil,
        contentMode: ContentMode = .fit,
        accessibilityLabel: String? = nil
    ) {
        self.manager = manager
        self.width = width
        self.height = height
        self.contentMode = contentMode
        self.accessibilityLabel = accessibilityLabel
    }

    public var body: some View {
        Image(manager.currentImageName)
            .resizable()
            .aspectRatio(contentMode: contentMode)
            .frame(maxWidth: width, maxHeight: height)
            .accessibilityLabel(accessibilityLabel ?? "")
            .accessibilityHidden(accessibilityLabel == nil)
            .onAppear {
                if reduceMotion { manager.pause() }
            }
            .onChange(of: reduceMotion) { reduced in
                reduced ? manager.pause() : manager.play()
            }
    }
}
