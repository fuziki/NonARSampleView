//
//  ARViewWrapper.swift
//  NonARSampleView
//
//  Created by fuziki on 2025/03/30.
//

import SwiftUI
import RealityKit

#if os(iOS)
typealias ViewRepresentable = UIViewRepresentable
#elseif os(macOS)
typealias ViewRepresentable = NSViewRepresentable
#endif

struct ARViewWrapper: ViewRepresentable {
    class Coordinator: NSObject {
        weak var arView: ARView?
        let arViewWrapper: ARViewWrapper
        var displayLink: CADisplayLink?

        init(arViewWrapper: ARViewWrapper) {
            self.arViewWrapper = arViewWrapper
        }

        deinit {
            displayLink?.invalidate()
        }

        @MainActor func setup(arView: ARView) {
            CAMetalLayer.setupLastNextDrawableTexture()
            self.arView = arView
#if os(iOS)
            displayLink = CADisplayLink(target: self, selector: #selector(update))
#elseif os(macOS)
            displayLink = arView.displayLink(target: self, selector: #selector(update))
#endif
            displayLink?.add(to: .main, forMode: .default)
        }

        @MainActor
        @objc func update(_ displayLink: CADisplayLink) {
            guard let arView else { return }
            arViewWrapper.updateHandler(arView)
        }
    }

    private let configureHander: ((ARView) -> Void)
    private let updateHandler: ((ARView) -> Void)

    init(configureHander: @escaping ((ARView) -> Void),
         updateHandler: @escaping ((ARView) -> Void)) {
        self.configureHander = configureHander
        self.updateHandler = updateHandler
    }

#if os(iOS)
    func makeUIView(context: Context) -> ARView {
        let arView: ARView = ARView(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        configureHander(arView)
        context.coordinator.setup(arView: arView)
        return arView
    }

    func updateUIView(_ arView: ARView, context: Context) {}
#elseif os(macOS)
    func makeNSView(context: Context) -> ARView {
        let arView: ARView = ARView(frame: .zero)
        configureHander(arView)
        context.coordinator.setup(arView: arView)
        return arView
    }

    func updateNSView(_ nsView: ARView, context: Context) {}
#endif

    func makeCoordinator() -> Coordinator {
        .init(arViewWrapper: self)
    }
}
