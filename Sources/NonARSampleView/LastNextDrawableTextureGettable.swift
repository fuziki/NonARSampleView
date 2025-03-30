//
//  LastNextDrawableTextureGettable.swift
//  NonARSampleView
//
//  Created by Tomoki Morita on 2025/03/30.
//

import Foundation
import Metal
import MetalKit

public protocol LastNextDrawableTextureGettable {
    static func setupLastNextDrawableTexture()
    var lastNextDrawableTexture: MTLTexture? { get }
}

extension LastNextDrawableTextureGettable where Self: CAMetalLayer {
    public static func setupLastNextDrawableTexture() {
        Self.swizzling()
    }
    public var lastNextDrawableTexture: MTLTexture? {
        return cachedLastNextDrawableTexture
    }
}

extension CAMetalLayer {
    private struct AssociatedObjectKeyList {
        nonisolated(unsafe) static var lastNextDrawableTextureKey = "lastNextDrawableTextureKey"
    }

    fileprivate static func swizzling() {
        _ = runSwizzling
    }

    fileprivate var cachedLastNextDrawableTexture: MTLTexture? {
        get {
            objc_getAssociatedObject(self, &AssociatedObjectKeyList.lastNextDrawableTextureKey) as? MTLTexture
        }
        set {
            objc_setAssociatedObject(self, &AssociatedObjectKeyList.lastNextDrawableTextureKey, newValue, .OBJC_ASSOCIATION_RETAIN)
        }
    }

    // avoid multiple calls
    nonisolated(unsafe) private static var runSwizzling: Void = {
        let cls = CAMetalLayer.self
        let original = class_getInstanceMethod(cls, #selector(nextDrawable))!
        let swizzling = class_getInstanceMethod(cls, #selector(swizzled_nextDrawable))!
        method_exchangeImplementations(original, swizzling)
    }()

    @objc private func swizzled_nextDrawable() -> CAMetalDrawable? {
        let swizzled = swizzled_nextDrawable()
        cachedLastNextDrawableTexture = swizzled?.texture
        return swizzled
    }
}
