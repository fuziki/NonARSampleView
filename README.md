# NonARSampleView

NonARSampleView is a sample implementation using RealityKit in non-AR mode.  
This project demonstrates how to utilize RealityKit for rendering 3D content without requiring AR capabilities.

<img src="docs/video.gif">

# Requirements
* iOS 16 or later.

# Installation

Add the following line to your Package.swift file to indicate that the framework depends on NonARSampleView:

```swift
let package = Package(
    dependencies: [
        .package(url: "https://github.com/fuziki/NonARSampleView.git", from: "0.1.0")
    ],
)
```

# Usage

Download a USDZ model from Apple's website at [Apple's AR Quick Look Gallery](https://developer.apple.com/augmented-reality/quick-look/), and use the URL to display the model with NonARSampleView.

```swift
let url = Bundle.module.url(forResource: "toy_biplane_idle", withExtension: "usdz")
NonARSampleView(modelURL: url)
    .postEffect { context in
        let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
        blitEncoder?.endEncoding()
    }
    .ignoresSafeArea()
```
