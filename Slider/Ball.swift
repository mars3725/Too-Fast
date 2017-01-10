//
//  Ball.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/24/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class Ball: SKShapeNode {
    var motherCart:Cart?
    
    init(color: SKColor, diameter: CGFloat) {
        super.init()
        self.path = CGPath(ellipseIn: CGRect(x: 0, y: 0, width: diameter, height: diameter), transform: nil)
        self.zPosition = zLayers.balls.rawValue
        self.strokeColor = SKColor.black
        self.fillColor = color
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
