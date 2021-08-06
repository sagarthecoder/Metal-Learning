//
//  HomepageViewController.swift
//  MetalLearning
//
//  Created by sz ashik on 6/8/21.
//

import UIKit
import MetalKit

enum Colors {
    static let greenColor = MTLClearColor(red: 0.0, green: 0.4, blue: 0.21, alpha: 1.0)
}
class HomepageViewController: UIViewController {

    @IBOutlet weak var metalView: MTKView!
    var device : MTLDevice!
    var commandQueue : MTLCommandQueue!
    let vertices : [Float] = [
        0,1,0,
        -1,-1,0,
        1,-1,0
    ]
    var pipelineState : MTLRenderPipelineState?
    var vertexBuffer : MTLBuffer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("HomeVC")
        metalView.device = MTLCreateSystemDefaultDevice()
        device = metalView.device
        metalView.clearColor = Colors.greenColor
        metalView.delegate = self
        commandQueue = device.makeCommandQueue()
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
    
    private func buildModel() {
        vertexBuffer = device.makeBuffer(bytes: vertices, length: vertices.count * MemoryLayout<Float>.size, options: [])
    }
    
    private func buildPipelineState() {
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_shader")
        let fragmentFunction = library?.makeFunction(name: "fragment_shader")
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm
        
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
        guard let drawable = view.currentDrawable, let descriptor = view.currentRenderPassDescriptor, let pipelineState = pipelineState else {
            return
        }
        let commandBuffer = commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeRenderCommandEncoder(descriptor: descriptor)
        commandEncoder?.setRenderPipelineState(pipelineState)
        commandEncoder?.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
        commandEncoder?.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: vertices.count)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
    }
}
