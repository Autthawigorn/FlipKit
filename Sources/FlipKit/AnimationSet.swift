import Foundation

// MARK: - AnimationSet
/// Represents a single animation set with its own frame data and loop logic
public struct AnimationSet {
    public let frames: [AnimationFrame]
    public var loopMode: LoopMode

    public init(frames: [AnimationFrame], loopMode: LoopMode = .holdLastFrame) {
        self.frames = frames
        self.loopMode = loopMode
    }

    /// Convenience: Create set with uniform frame durations
    public static func uniform(
        imageNames: [String],
        duration: TimeInterval = 1.0,
        loopMode: LoopMode = .holdLastFrame
    ) -> AnimationSet {
        AnimationSet(
            frames: imageNames.map { AnimationFrame($0, duration: duration) },
            loopMode: loopMode
        )
    }

    /// Convenience: Create set from numbered file patterns (e.g., "walk_01", "walk_02")
    public static func numbered(
        prefix: String,
        frames: Int,
        startIndex: Int = 1,
        padded: Bool = true,
        duration: TimeInterval = 1.0,
        loopMode: LoopMode = .holdLastFrame
    ) -> AnimationSet {
        let frames = (startIndex..<startIndex + frames).map { i -> AnimationFrame in
            let name = padded ? "\(prefix)\(String(i).leftPadded(toLength: 2))" : "\(prefix)\(i)"
            return AnimationFrame(name, duration: duration)
        }
        return AnimationSet(frames: frames, loopMode: loopMode)
    }
}

// MARK: - Private Helpers
private extension String {
    func leftPadded(toLength length: Int, with character: Character = "0") -> String {
        count >= length ? self : String(repeating: character, count: length - count) + self
    }
}
