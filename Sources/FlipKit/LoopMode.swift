import Foundation

// MARK: - LoopMode
public enum LoopMode {
    case loop(count: Int)   // 0 = Infinite loop
    case holdLastFrame      // Stay on the final frame after completion
}
