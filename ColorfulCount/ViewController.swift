//
//  ViewController.swift
//  ColorfulCount
//
//  Created by クワシマ・ユウキ on 2022/07/20.
//

import UIKit
import MetalKit

class ViewController: UIViewController{

    var mainRenderer: YuruAbstractRenderer?
    
    @IBOutlet var label: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainRenderer = YuruMainRenderer(functionName: "test", width: Int(self.view.frame.width), height: Int(self.view.frame.height))

        let metalView = MTKView(frame: CGRect(x: 0, y: 0, width: self.view.frame.width, height: self.view.frame.height), device: (UIApplication.shared.delegate as! AppDelegate).device)
        metalView.colorPixelFormat = .bgra8Unorm
        metalView.framebufferOnly = false
        metalView.drawableSize = CGSize(width: self.view.frame.width, height: self.view.frame.height)
        metalView.delegate = mainRenderer as! MTKViewDelegate
        self.view.addSubview(metalView)
        
        self.view.bringSubviewToFront(label)
        // Do any additional setup after loading the view.
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        super.touchesBegan(touches, with: event)
        (mainRenderer as! YuruMainRenderer).args[1] += 1
        label.text = String(Int((mainRenderer as! YuruMainRenderer).args[1]))
    }

}

