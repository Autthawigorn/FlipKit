import Foundation

// MARK: - AnimationFrame
public struct AnimationFrame {
    public let imageName: String
    public var duration: TimeInterval

    public init(_ imageName: String, duration: TimeInterval = 0.1) {
        self.imageName = imageName
        self.duration = duration
    }
}

