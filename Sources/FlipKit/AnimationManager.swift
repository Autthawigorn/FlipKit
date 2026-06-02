import Foundation
import Combine
import SwiftUI

// MARK: - AnimationManager (ViewModel)
/// Manages multiple AnimationSets in sequence, supporting individual and sequence-wide loops
@MainActor
public class AnimationManager: ObservableObject {

    // MARK: Published
    @Published public private(set) var currentImageName: String = ""
    @Published public private(set) var currentSetIndex: Int = 0
    @Published public private(set) var isPlaying: Bool = false

    // MARK: Config
    private let sets: [AnimationSet]
    private let sequenceLoopMode: LoopMode   // Loop behavior for the entire sequence
    private let onSetComplete: ((Int) -> Void)?
    private let onSequenceComplete: (() -> Void)?

    // MARK: Internal state
    private var frameIndex: Int = 0
    private var setLoopCount: Int = 0
    private var sequenceLoopCount: Int = 0
    private var timer: Timer?

    // MARK: Init
    public init(
        sets: [AnimationSet],
        sequenceLoopMode: LoopMode = .holdLastFrame,
        autoPlay: Bool = true,
        onSetComplete: ((Int) -> Void)? = nil,
        onSequenceComplete: (() -> Void)? = nil
    ) {
        self.sets = sets
        self.sequenceLoopMode = sequenceLoopMode
        self.onSetComplete = onSetComplete
        self.onSequenceComplete = onSequenceComplete

        if let first = sets.first?.frames.first {
            currentImageName = first.imageName
        }
        if autoPlay { play() }
    }

    // MARK: - Public Controls

    public func play() {
        guard !sets.isEmpty, !isPlaying else { return }
        isPlaying = true
        scheduleNextFrame()
    }

    public func pause() {
        timer?.invalidate()
        timer = nil
        isPlaying = false
    }

    public func stop() {
        pause()
        currentSetIndex = 0
        frameIndex = 0
        setLoopCount = 0
        sequenceLoopCount = 0
        currentImageName = sets.first?.frames.first?.imageName ?? ""
    }

    public func restart() {
        stop()
        play()
    }

    /// Jump to a specific AnimationSet immediately
    public func jump(toSet index: Int) {
        guard index < sets.count else { return }
        pause()
        currentSetIndex = index
        frameIndex = 0
        setLoopCount = 0
        currentImageName = sets[index].frames.first?.imageName ?? ""
        play()
    }

    // MARK: - Private Logic

    private var currentSet: AnimationSet { sets[currentSetIndex] }

    private func scheduleNextFrame() {
        let frame = currentSet.frames[frameIndex]
        timer = Timer.scheduledTimer(withTimeInterval: frame.duration, repeats: false) { [weak self] _ in
            Task { @MainActor [weak self] in
                self?.advance()
            }
        }
    }

    private func advance() {
        let nextFrame = frameIndex + 1

        if nextFrame < currentSet.frames.count {
            // Still within the current animation set
            frameIndex = nextFrame
            currentImageName = currentSet.frames[frameIndex].imageName
            scheduleNextFrame()
        } else {
            // Current set cycle completed
            setLoopCount += 1

            switch currentSet.loopMode {
            case .loop(let count) where count == 0 || setLoopCount < count:
                // Continue looping within current set
                frameIndex = 0
                currentImageName = currentSet.frames[0].imageName
                scheduleNextFrame()

            default:
                // Set finished, transition to next set
                onSetComplete?(currentSetIndex)
                advanceToNextSet()
            }
        }
    }

    private func advanceToNextSet() {
        let nextSet = currentSetIndex + 1

        if nextSet < sets.count {
            // Move to the next set
            currentSetIndex = nextSet
            frameIndex = 0
            setLoopCount = 0
            currentImageName = currentSet.frames[0].imageName
            scheduleNextFrame()
        } else {
            // Entire sequence cycle completed
            sequenceLoopCount += 1

            switch sequenceLoopMode {
            case .loop(let count) where count == 0 || sequenceLoopCount < count:
                // Restart the entire sequence
                currentSetIndex = 0
                frameIndex = 0
                setLoopCount = 0
                currentImageName = sets[0].frames[0].imageName
                scheduleNextFrame()

            default:
                // Finished all sets, hold on the final frame
                isPlaying = false
                onSequenceComplete?()
            }
        }
    }
}
