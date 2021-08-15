//
//  Texurable.swift
//  MetalLearning
//
//  Created by sz ashik on 15/8/21.
//

import Foundation
import MetalKit
import UIKit
import Photos

class Texturable : NSObject {
    func setTexure (device : MTLDevice, cgImage : CGImage)-> MTLTexture {
        let textureLoader = MTKTextureLoader(device: device)
        var texture : MTLTexture? = nil
        var textureLoaderOptions =  [
            MTKTextureLoader.Option.origin : nil
        ] as [MTKTextureLoader.Option : Any?]
        if #available(iOS 10.0, *) {
            textureLoaderOptions =  [
                MTKTextureLoader.Option.origin : NSString(string: MTKTextureLoader.Origin.bottomLeft.rawValue)
            ]
        } else {
            textureLoaderOptions =  [
                MTKTextureLoader.Option.origin : nil
            ] as [MTKTextureLoader.Option : Any?]
        }
        
        do {
            texture = try textureLoader.newTexture(cgImage: cgImage, options: textureLoaderOptions as [MTKTextureLoader.Option : Any])
        } catch {
            print("Error")
        }
        return texture!
    }
}
