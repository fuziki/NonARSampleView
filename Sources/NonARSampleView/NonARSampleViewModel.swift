//
//  NonARSampleViewModel.swift
//
//
//  Created by fuziki on 2024/07/23.
//

import Combine
import RealityKit
import SwiftUI

class NonARSampleViewModel: ObservableObject {
    private enum NonARSampleError: Error {
        case noModelURL
    }

    // Constants
    private let len: Float = 0.8
    private let regex = /resourceNotFound\("([^"]+)"\)/

    // Outputs
    var errorText: String?

    // Entities
    private var plane: ModelEntity!
    private var camera: PerspectiveCamera!

    // Properteis
    private let modelURL: URL?
    private var beforeCameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)
    private var cameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)
    private var cancellables: Set<AnyCancellable> = []

    init(modelURL: URL?) {
        self.modelURL = modelURL
    }

    func configure(arView: ARView) {
        do {
            guard let modelURL else {
                throw NonARSampleError.noModelURL
            }

            plane = try ModelEntity.loadModel(contentsOf: modelURL)
            plane.availableAnimations.forEach {
                plane.playAnimation($0.repeat())
            }

            // Camera
            camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 60
            camera.look(at: .zero, from: [0, 0.5, 1], relativeTo: nil)

            // Environment
            // Not work on Swift Package. (Xcode 15.2)
//            let skybox = try EnvironmentResource.load(named: "alps_field_1k", in: .module)
//            arView.environment.background = .skybox(skybox)

            let skyboxTexture = try TextureResource.load(named: "alps_field_1k", in: .module)
            var skyboxMaterial = UnlitMaterial()
            skyboxMaterial.color = .init(texture: .init(skyboxTexture))
            let skyboxComponent = ModelComponent(mesh: .generateSphere(radius: 1000), materials: [skyboxMaterial])

            let skybox = Entity()
            skybox.components.set(skyboxComponent)
            skybox.scale *= .init(1, 1, -1)

            // Lighting
            let directionalLight = DirectionalLight()
            directionalLight.light.color = .white
            directionalLight.light.intensity = 5000
            directionalLight.look(at: .zero, from: .init(x: 0, y: 20, z: 5), relativeTo: nil)

            // WorldAnchor
            let worldAnchor = AnchorEntity(world: .zero)
            worldAnchor.addChild(plane)
            worldAnchor.addChild(camera)
            worldAnchor.addChild(skybox)
            worldAnchor.addChild(directionalLight)
            arView.scene.anchors.append(worldAnchor)

            arView.scene
                .publisher(for:  SceneEvents.Update.self)
                .sink { [weak self] (_: SceneEvents.Update) in
                    self?.updateEvent()
                }
                .store(in: &cancellables)
        } catch NonARSampleError.noModelURL {
            errorText = """
modelURL is nil.
Please download it from "https://developer.apple.com/augmented-reality/quick-look/".
"""
        } catch {
            var errorText = error.localizedDescription
            if let result = "\(error)".firstMatch(of: regex) {
                errorText += """


"\(result.1)" not found.
Please download usdz from "https://developer.apple.com/augmented-reality/quick-look/".
"""
            }
            self.errorText = errorText
        }
    }

    private func updateEvent() {
        camera.position = plane.position + .init(
            x: len * sin(cameraRot.yaw) * cos(cameraRot.pitch),
            y: len * sin(cameraRot.pitch),
            z: len * cos(cameraRot.yaw) * cos(cameraRot.pitch)
        )

        camera.look(
            at: plane.position,
            from: camera.position,
            relativeTo: nil
        )
    }

    func onChangedDragGesture(value: DragGesture.Value) {
        cameraRot = calcCameraRot(
            beforeCameraRot: beforeCameraRot,
            translation: value.translation
        )
    }

    func onEndedDragGesture(value: DragGesture.Value) {
        cameraRot = calcCameraRot(
            beforeCameraRot: beforeCameraRot,
            translation: value.translation
        )
        beforeCameraRot = cameraRot
    }

    private func calcCameraRot(
        beforeCameraRot: (yaw: Float, pitch: Float),
        translation: CGSize
    ) -> (yaw: Float, pitch: Float) {
        (yaw: beforeCameraRot.yaw - Float(translation.width) * .pi / 180,
         pitch: min(max(beforeCameraRot.pitch + Float(translation.height) * .pi / 180, 0), .pi / 2))
    }

    func postProcess(context: ARView.PostProcessContext) {
        let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
        blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
        blitEncoder?.endEncoding()
    }
}
