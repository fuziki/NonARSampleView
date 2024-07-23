//
//  ARViewWrapper.swift
//
//
//  Created by fuziki on 2024/07/23.
//

import SwiftUI
import RealityKit

struct ARViewWrapper: UIViewRepresentable {
    typealias UIViewType = ARView

    class Coordinator {
        var realityView: UIViewType?
    }

    private let configureHander: ((UIViewType) -> Void)
    private let postEffectHandler: ((ARView.PostProcessContext) -> Void)

    init(configureHander: @escaping ((UIViewType) -> Void),
         postEffectHandler: @escaping ((ARView.PostProcessContext) -> Void)) {
        self.configureHander = configureHander
        self.postEffectHandler = postEffectHandler
    }

    func makeUIView(context: Context) -> UIViewType {
        let arView = UIViewType(frame: .zero, cameraMode: .nonAR, automaticallyConfigureSession: false)
        arView.renderCallbacks.postProcess = postEffectHandler
        configureHander(arView)
        context.coordinator.realityView = arView
        return arView
    }

    func updateUIView(_ view: UIViewType, context: Context) {
    }

    func makeCoordinator() -> Coordinator {
        .init()
    }
}
