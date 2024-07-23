//
//  NonARSampleView.swift
//
//
//  Created by fuziki on 2024/07/23.
//

import RealityKit
import SwiftUI

public struct NonARSampleView: View {
    @StateObject private var vm: NonARSampleViewModel
    private var postEffectHandler: ((ARView.PostProcessContext) -> Void)?

    public init(modelURL: URL?) {
        _vm = .init(wrappedValue: .init(modelURL: modelURL))
    }

    public var body: some View {
        ARViewWrapper { arView in
            vm.configure(arView: arView)
        } postEffectHandler: { context in
            if let postEffectHandler {
                postEffectHandler(context)
            } else {
                vm.postProcess(context: context)
            }
        }
        .gesture(DragGesture(minimumDistance: 0)
            .onChanged { (value: DragGesture.Value) in
                vm.onChangedDragGesture(value: value)
            }
            .onEnded { (value: DragGesture.Value) in
                vm.onEndedDragGesture(value: value)
            }
        )
        .overlay {
            if let errorText = vm.errorText {
                Text(errorText)
                    .foregroundStyle(Color.white)
                    .multilineTextAlignment(.center)
            }
        }
    }

    public func postEffect(handler: @escaping (ARView.PostProcessContext) -> Void) -> some View {
        var this = self
        this.postEffectHandler = handler
        return this
    }
}

#Preview {
    let url = Bundle.module.url(forResource: "toy_biplane_idle", withExtension: "usdz")
    return NonARSampleView(modelURL: url)
        .postEffect { context in
            let blitEncoder = context.commandBuffer.makeBlitCommandEncoder()
            blitEncoder?.copy(from: context.sourceColorTexture, to: context.targetColorTexture)
            blitEncoder?.endEncoding()
        }
        .ignoresSafeArea()
}
