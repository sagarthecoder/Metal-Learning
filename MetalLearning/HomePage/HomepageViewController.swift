//
//  HomepageViewController.swift
//  MetalLearning
//
//  Created by sz ashik on 6/8/21.
//

import UIKit
import MetalKit
import simd

enum Colors {
    static let greenColor = MTLClearColor(red: 0.0, green: 0.4, blue: 0.21, alpha: 1.0)
}
class HomepageViewController: UIViewController {

    @IBOutlet weak var metalView: MTKView!
    var device : MTLDevice!
    var commandQueue : MTLCommandQueue!
    var vertices : [Vertex] = [
        Vertex(position: SIMD3<Float>(-1, 1, 0), color: SIMD4<Float>(1, 0, 0, 1), texture: SIMD2<Float>(0, 1)), // V0
        Vertex(position: SIMD3<Float>(-1, -1, 0), color: SIMD4<Float>(0, 1, 0, 1), texture: SIMD2<Float>(0, 0)), // V1
        Vertex(position: SIMD3<Float>(1, -1, 0), color: SIMD4<Float>(0, 0, 1, 1), texture: SIMD2<Float>(1, 0)), // V2
        Vertex(position: SIMD3<Float>(1, 1, 0), color: SIMD4<Float>(1, 0, 1, 1), texture: SIMD2<Float>(1, 1)) // v3
    ]
    
    var indices : [UInt16] = [
        0, 1, 2,
        2, 3, 0
    ]
    
    struct Constants {
        var animateBy : Float = 0.0
    }
    
    var constants = Constants()
    var time : Float = 0.0
    var pipelineState : MTLRenderPipelineState?
    var vertexBuffer : MTLBuffer?
    var indexBuffer : MTLBuffer?
    var texture : MTLTexture? = nil
    var samplerState : MTLSamplerState?
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeVC")
        metalView.device = MTLCreateSystemDefaultDevice()
        device = metalView.device
        metalView.clearColor = Colors.greenColor
        metalView.delegate = self
        commandQueue = device.makeCommandQueue()
        buildSamplerState()
        let texurable = Texturable()
        let image = UIImage(named: "2")
        let cgImage : CGImage = (image?.cgImage)!
        self.texture = texurable.setTexure(device: device, cgImage : cgImage)
        buildModel()
        buildPipelineState()
//        let commandBuffer = commandQueue.makeCommandBuffer()
//        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: metalView.currentRenderPassDescriptor!)
//
//        commandEncoder?.endEncoding()
//        commandBuffer?.present(metalView.currentDrawable!)
//        commandBuffer?.commit()
        // Do any additional setup after loading the view.
    }
    func buildSamplerState() {
        let descriptor = MTLSamplerDescriptor()
        descriptor.minFilter = .linear
        descriptor.magFilter = .linear
        samplerState = device.makeSamplerState(descriptor : descriptor)
    }
    private func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Vertex>.stride, options: [])
        indexBuffer = device.makeBuffer(bytes: indices, length: indices.count *  MemoryLayout<UInt16>.size, options: [])
    }
    
    private func buildPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "texured_fragment")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        vertexDescriptor.attributes[1].format = .float4
        vertexDescriptor.attributes[1].offset = MemoryLayout<float3>.stride
        vertexDescriptor.attributes[1].bufferIndex = 0
        vertexDescriptor.attributes[2].format = .float2
        vertexDescriptor.attributes[2].offset = MemoryLayout<float3>.stride + MemoryLayout<float4>.stride
        vertexDescriptor.attributes[2].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<Vertex>.stride
        
        pipelineDescriptor.vertexDescriptor = vertexDescriptor
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch {
            print("error = \(error.localizedDescription)")
        }
    }

}

extension HomepageViewController : MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        
    }
    
    func draw(in view: MTKView) {
        guard let drawable = view.currentDrawable, let descriptor = view.currentRenderPassDescriptor, let pipelineState = pipelineState, let indexBuffer = indexBuffer else {
            return
        }
       // time += (1.0/Float(view.preferredFramesPerSecond))
       // constants.animateBy = abs(sin(time)/2 + 0.5)
       // print("draw")
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        
        commandEncoder?.setFragmentTexture(self.texture, index: 0)
        commandEncoder?.setFragmentSamplerState(samplerState, index: 0)
        //commandEncoder?.setVertexBytes(&constants, length: MemoryLayout<Constants>.stride, index: 1)
       // commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder?.drawIndexedPrimitives(type: .triangle, indexCount: indices.count, indexType: .uint16, indexBuffer: indexBuffer, indexBufferOffset: 0)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
}
