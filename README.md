# FlipKit

> SwiftUI Sequence Image Animation Package — chain multiple animation sets, control playback, and react to completion events with ease.

---

## Overview

**FlipKit** lets you play sprite-sheet–style animations from image assets on iOS and macOS. Define animation sets with per-frame durations, chain them in a sequence, control each set's loop behaviour independently, and receive callbacks when a set or the full sequence finishes.

---

## Requirements

| | Minimum |
|---|---|
| iOS | 16.0+ |
| macOS | 13.0+ |
| Swift | 6.3+ |
| Xcode | 15.0+ |

---

## Installation

### Swift Package Manager

Add the dependency in **Xcode**:

1. Go to **File → Add Package Dependencies…**
2. Paste the URL below
3. Select **FlipKit** as the package product

```
https://github.com/Autthawigorn/FlipKit.git
```

Or add it directly to `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/Autthawigorn/FlipKit.git", from: "1.0.0")
],
targets: [
    .target(
        name: "YourTarget",
        dependencies: ["FlipKit"]
    )
]
```

---

## Core Concepts

### AnimationFrame

A single frame in an animation — an image asset name paired with a display duration.

```swift
let frame = AnimationFrame("walk_01", duration: 0.08)
```

| Property | Type | Default | Description |
|---|---|---|---|
| `imageName` | `String` | — | Name of the image asset |
| `duration` | `TimeInterval` | `0.1` | How long this frame is displayed (in seconds) |

---

### LoopMode

Controls what happens when an animation set (or the full sequence) finishes playing.

```swift
public enum LoopMode {
    case loop(count: Int)   // 0 = infinite loop
    case holdLastFrame      // freeze on the final frame
}
```

| Case | Description |
|---|---|
| `.loop(count: 0)` | Loop forever |
| `.loop(count: n)` | Loop exactly `n` times then move on |
| `.holdLastFrame` | Stop and stay on the final frame |

---

### AnimationSet

A group of frames that play together as one animation clip. Each set carries its own `LoopMode`.

**Manual initialisation:**
```swift
let frames = [
    AnimationFrame("idle_01", duration: 0.1),
    AnimationFrame("idle_02", duration: 0.1),
    AnimationFrame("idle_03", duration: 0.1),
]
let idleSet = AnimationSet(frames: frames, loopMode: .loop(count: 0))
```

**Uniform convenience** — same duration for every frame:
```swift
let runSet = AnimationSet.uniform(
    imageNames: ["run_01", "run_02", "run_03", "run_04"],
    duration: 0.06,
    loopMode: .loop(count: 2)
)
```

**Numbered convenience** — auto-generates names from a prefix and frame count:
```swift
// Produces: "walk_01", "walk_02", … "walk_08"
let walkSet = AnimationSet.numbered(
    prefix: "walk_",
    frames: 8,
    startIndex: 1,
    padded: true,       // zero-pads to two digits
    duration: 0.08,
    loopMode: .holdLastFrame
)
```

---

### AnimationManager

The `@MainActor` `ObservableObject` that drives the entire sequence. It plays through each `AnimationSet` in order, applying per-set and per-sequence loop rules.

```swift
@StateObject private var manager = AnimationManager(
    sets: [idleSet, runSet, walkSet],
    sequenceLoopMode: .loop(count: 0),
    autoPlay: true,
    onSetComplete: { index in
        print("Finished set \(index)")
    },
    onSequenceComplete: {
        print("All sets finished")
    }
)
```

**Published properties:**

| Property | Type | Description |
|---|---|---|
| `currentImageName` | `String` | The image asset name to display right now |
| `currentSetIndex` | `Int` | Index of the animation set currently playing |
| `isPlaying` | `Bool` | Whether the animation is actively running |

**Playback controls:**

| Method | Description |
|---|---|
| `play()` | Start or resume playback |
| `pause()` | Pause on the current frame |
| `stop()` | Pause and reset to the very first frame |
| `restart()` | Stop then immediately play from the beginning |
| `jump(toSet:)` | Skip directly to a specific animation set by index |

---

### SequenceImageView

A ready-to-use SwiftUI `View` that renders whichever frame `AnimationManager` is pointing to. Automatically pauses when the system **Reduce Motion** accessibility setting is enabled.

```swift
SequenceImageView(
    manager: manager,
    width: 200,
    height: 200,
    contentMode: .fit,
    accessibilityLabel: "Character walking animation"
)
```

| Parameter | Type | Default | Description |
|---|---|---|---|
| `manager` | `AnimationManager` | — | The manager driving this view |
| `width` | `CGFloat?` | `nil` | Max display width (`nil` = unconstrained) |
| `height` | `CGFloat?` | `nil` | Max display height (`nil` = unconstrained) |
| `contentMode` | `ContentMode` | `.fit` | `.fit` or `.fill` |
| `accessibilityLabel` | `String?` | `nil` | VoiceOver label — pass `nil` to treat as decorative and hide from accessibility |

---

## Quick Start

```swift
import SwiftUI
import FlipKit

struct CharacterView: View {

    @StateObject private var manager = AnimationManager(
        sets: [
            // Idle: loop forever
            AnimationSet.numbered(
                prefix: "idle_",
                frames: 4,
                duration: 0.12,
                loopMode: .loop(count: 0)
            ),
            // Attack: play once, then hold
            AnimationSet.numbered(
                prefix: "attack_",
                frames: 6,
                duration: 0.07,
                loopMode: .holdLastFrame
            ),
        ],
        sequenceLoopMode: .holdLastFrame,
        autoPlay: true
    )

    var body: some View {
        VStack(spacing: 24) {
            SequenceImageView(
                manager: manager,
                width: 160,
                height: 160,
                accessibilityLabel: "Character animation"
            )

            HStack(spacing: 16) {
                Button("Play")    { manager.play() }
                Button("Pause")   { manager.pause() }
                Button("Restart") { manager.restart() }
                Button("Attack")  { manager.jump(toSet: 1) }
            }
            .buttonStyle(.bordered)
        }
        .padding()
    }
}
```

---

## Architecture

```
LoopMode                — shared enum controlling loop behaviour (per-set & per-sequence)

AnimationFrame          — one image asset name + display duration
      ↓
AnimationSet            — ordered frames + own LoopMode
      │                   factory methods: .uniform() / .numbered()
      ↓
AnimationManager        — sequences multiple sets, drives the Timer,
      │                   publishes currentImageName / currentSetIndex / isPlaying
      ↓
SequenceImageView       — SwiftUI view: renders current frame,
                          respects Reduce Motion, supports VoiceOver label
```

---

## License

This project is available under the **MIT License**. See `LICENSE` for details.
