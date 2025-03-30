//
//  ContentView.swift
//  ExampleApp
//
//  Created by fuziki on 2025/03/30.
//

import NonARSampleView
import RealityKit
import SwiftUI

#if os(iOS)
typealias MyImage = UIImage
extension Image {
    init(myImage: MyImage) {
        self.init(uiImage: myImage)
    }
}
#elseif os(macOS)
typealias MyImage = NSImage
extension Image {
    init(myImage: MyImage) {
        self.init(nsImage: myImage)
    }
}
#endif

struct ContentView: View {
    @State var myImage: MyImage?
    @AppStorage("preview") var preview = false

    var body: some View {
        NonARSampleView()
            .update { arView in
                if !preview { return }
#if os(iOS)
                guard let sublayers = arView.layer.sublayers,
                      let targetLayer = sublayers.first(where: { $0 is CAMetalLayer }) else {
                    return
                }
#elseif os(macOS)
                guard let targetLayer = arView.layer else {
                    return
                }
#endif
                guard let tex = (targetLayer as? CAMetalLayer)?.lastNextDrawableTexture,
                      let ci = CIImage(mtlTexture: tex) else {
                    return
                }
                let transform = CGAffineTransform(translationX: 0, y: ci.extent.height).scaledBy(x: 1, y: -1)
                let flipped = ci.transformed(by: transform)
                guard let cg = CIContext().createCGImage(flipped, from: flipped.extent) else {
                    return
                }
#if os(iOS)
                myImage = MyImage(cgImage: cg)
#elseif os(macOS)
                myImage = MyImage(cgImage: cg, size: ci.extent.size)
#endif
            }
            .ignoresSafeArea()
            .overlay(alignment: .bottomLeading) {
                VStack {
                    if preview, let myImage {
                        Image(myImage: myImage)
                            .resizable()
                            .scaledToFit()
                            .border(Color.black, width: 3)
                    }
                    Toggle("Preview", isOn: $preview)
                        .padding(.horizontal, 16)
                }
                .frame(width: 150)
            }
    }
}

#Preview {
    ContentView()
}
