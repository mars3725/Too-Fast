//
//  Button.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/28/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class Button: SKShapeNode {
    fileprivate var image: SKSpriteNode?
    var tapAction: SKAction?
    
    init(imageNamed: String?, color: SKColor = SKColor.lightGray) {
        super.init()
        self.isUserInteractionEnabled = true
        let path = CGMutablePath()
        path.addArc(center: CGPoint.zero, radius: 30, startAngle: 0, endAngle: CGFloat(M_PI) * 2, clockwise: true)
        self.path = path
        self.fillColor = color
        self.strokeColor = SKColor.black
        
        if (imageNamed != nil) {
            image = SKSpriteNode(imageNamed: imageNamed!)
            self.addChild(image!)
        }
    }
    
    func setImage(named name: String) {
        if image == nil {
            image = SKSpriteNode(imageNamed: name)
            self.addChild(image!)
        } else {
            image!.texture = SKTexture(imageNamed: name)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func contains(_ p: CGPoint) -> Bool {
        if super.contains(p) {
            return true
        } else {
            return false
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.fillColor = SKColor.darkGray
        if soundEnabled {
            self.run(SKAction.playSoundFileNamed("tap.aif", waitForCompletion: true))
        }
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.fillColor = SKColor.lightGray
        if tapAction != nil {
            self.run(tapAction!)
        }
    }
}
