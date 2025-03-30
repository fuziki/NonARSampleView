//
//  NonARSampleViewModel.swift
//
//
//  Created by fuziki on 2024/07/23.
//

import Combine
import RealityKit
import SwiftUI

@Observable @MainActor
class NonARSampleViewModel {
    private(set) var errorText: String?

    private let len: Float = 0.8

    // Entities
    private var plane: Entity!
    private var camera: PerspectiveCamera!

    // Properties
    private var beforeCameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)
    private var cameraRot: (yaw: Float, pitch: Float) = (yaw: 0, pitch: 0)
    private var cancellables: Set<AnyCancellable> = []

    func configure(arView: ARView) {
        do {
            let scene = try Entity.load(named: "Scene", in: nonARSampleViewBundle)

            plane = scene.children
                .first(where: { $0.name == "Root" })!.children
                .first(where: { $0.name == "ToyBiplane" })

            // Camera
            camera = PerspectiveCamera()
            camera.camera.fieldOfViewInDegrees = 60
            camera.look(at: .zero, from: [0, 0.5, 1], relativeTo: nil)
            
            // WorldAnchor
            let worldAnchor = AnchorEntity(world: .zero)
            worldAnchor.addChild(scene)
            worldAnchor.addChild(camera)

            arView.scene.anchors.append(worldAnchor)

            arView.scene
                .publisher(for:  SceneEvents.Update.self)
                .sink { [weak self] (_: SceneEvents.Update) in
                    self?.updateEvent()
                }
                .store(in: &cancellables)
        } catch {
            errorText = error.localizedDescription
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
        (
            yaw: beforeCameraRot.yaw - Float(translation.width) * .pi / 180,
            pitch: min(max(beforeCameraRot.pitch + Float(translation.height) * .pi / 180, 0), .pi / 2)
        )
    }
}
