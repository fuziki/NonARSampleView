import Foundation
import RealityKit
import SwiftUI

/// Bundle for the NonARSampleView project
public let nonARSampleViewBundle = Bundle.module

@MainActor
public struct NonARSampleView: View {
    @State var vm: NonARSampleViewModel
    private var updateHandler: ((ARView) -> Void)?

    public init() {
        _vm = .init(wrappedValue: .init())
    }

    public var body: some View {
        ARViewWrapper { arView in
            vm.configure(arView: arView)
        } updateHandler: { arView in
            if let updateHandler {
                updateHandler(arView)
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
                    .foregroundStyle(Color.red)
                    .background(Color.white)
            }
        }
    }

    public func update(updateHandler: @escaping ((ARView) -> Void)) -> Self {
        var `self` = self
        self.updateHandler = updateHandler
        return self
    }
}

#Preview {
    NonARSampleView()
        .ignoresSafeArea()
}
