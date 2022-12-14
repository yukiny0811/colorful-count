//
//  YuruMainRenderer.swift
//  ColorfulCount
//
//  Created by クワシマ・ユウキ on 2022/07/20.
//

import Foundation
import MetalKit

class YuruMainRenderer: NSObject, YuruAbstractRenderer {
    var subReadTexture1: MTLTexture
    var subWriteTexture1: MTLTexture
    var pipelineState: MTLComputePipelineState
    
    let appDelegate: AppDelegate!
    
    var args: [Float] = [0.0, 0]
    var saveTime: Date!
    
    init(functionName: String, width: Int, height: Int) {
        
        appDelegate = UIApplication.shared.delegate as! AppDelegate
        
        let textureReadDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        textureReadDescriptor.usage = [.shaderRead]
        subReadTexture1 = appDelegate.device.makeTexture(descriptor: textureReadDescriptor)!
        
        let textureWriteDescriptor = MTLTextureDescriptor.texture2DDescriptor(pixelFormat: .bgra8Unorm, width: width, height: height, mipmapped: false)
        textureWriteDescriptor.usage = [.shaderWrite]
        subWriteTexture1 = appDelegate.device.makeTexture(descriptor: textureWriteDescriptor)!
        
        let function = appDelegate.library.makeFunction(name: functionName)!
        pipelineState = try! appDelegate.device.makeComputePipelineState(function: function)
        
        saveTime = Date()
    }
}

extension YuruMainRenderer: MTKViewDelegate {
    public func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    public func draw(in view: MTKView) {
        view.drawableSize = CGSize(width: view.frame.width, height: view.frame.height)
        guard let drawable = view.currentDrawable else {
            print("draw")
            return
        }
        self.args[0] += Float(Date().timeIntervalSince(saveTime))
        let threadsPerThreadgroup = MTLSize(width: 16, height: 16, depth: 1)
        let threadGroupCount = MTLSize(
            width: Int(ceilf(Float(view.frame.width) / Float(threadsPerThreadgroup.width))),
            height: Int(ceilf(Float(view.frame.height) / Float(threadsPerThreadgroup.height))),
            depth: 1)
        let startTime = Date()
        
        let argsBuffer = appDelegate.device.makeBuffer(bytes: args, length: MemoryLayout<Float>.stride * args.count, options: [])!
        
        let commandBuffer = appDelegate.commandQueue.makeCommandBuffer()
        let commandEncoder = commandBuffer?.makeComputeCommandEncoder()
        commandEncoder?.setComputePipelineState(pipelineState)
        commandEncoder?.setTexture(drawable.texture, index: 0)
        commandEncoder?.setTexture(subReadTexture1, index: 1)
        commandEncoder?.setTexture(subWriteTexture1, index: 2)
        commandEncoder?.setBuffer(argsBuffer, offset: 0, index: 0)
        commandEncoder?.dispatchThreadgroups(threadGroupCount, threadsPerThreadgroup: threadsPerThreadgroup)
        commandEncoder?.endEncoding()
        commandBuffer?.present(drawable)
        commandBuffer?.commit()
        
        let elapsedTime = Date().timeIntervalSince(startTime)
        print("elapsed: \(elapsedTime)")
        
        saveTime = Date()
    }
}
