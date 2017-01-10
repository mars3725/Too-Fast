//
//  Cart.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/21/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit

class Cart: SKShapeNode {
    var game = GameScene()
    var ballPositions = [CGPoint]()
    var balls = 0
    var location = CGPoint()
    var size = CGFloat()
    
    init(game: GameScene, color: SKColor) {
        super.init()
        self.path = CGPath(roundedRect: CGRect(x: 0, y: 0, width: game.cartSize, height: game.cartSize), cornerWidth: 10, cornerHeight: 10, transform: nil)
        self.game = game
        self.size = game.cartSize
        self.fillColor = color
        self.strokeColor = SKColor.black
        self.zPosition = zLayers.carts.rawValue
        
        ballPositions.append(CGPoint(x: self.frame.width * (1/4), y: self.frame.width * (1/4)))
        ballPositions.append(CGPoint(x: self.frame.width * (1/4), y: self.frame.width * (3/4)))
        ballPositions.append(CGPoint(x: self.frame.width * (3/4), y: self.frame.width * (1/4)))
        ballPositions.append(CGPoint(x: self.frame.width * (3/4), y: self.frame.width * (3/4)))
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func moveUp()->Bool {
        if !self.hasActions() && (location.y != game.rows-1 || (location.x == game.exitSquare.x && location.y+1 == game.exitSquare.y && balls == ballPositions.count))  {
            if let blockingCart = game.getCartAtLocation(CGPoint(x: location.x, y: location.y+1)) {
                if !blockingCart.moveUp() {
                    return false
                }
            }
            location.y += 1
            self.run(SKAction.move(by: CGVector(dx: 0, dy: size), duration: 0.2), completion: {
                if self.location.y == self.game.rows {
                    self.removeFromParent()
                    self.game.carts.remove(at: self.game.carts.index(of: self)!)
                    if soundEnabled {
                    self.run(SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false))
                    }
                    self.game.score += 1
                    self.game.scoreLabel.text = "Score: \(self.game.score)"
                }
            })
            return true
        }
        return false
    }
    
    func canExit() -> Bool {
        if location.x == game.exitSquare.x && location.y+1 == game.exitSquare.y && balls == ballPositions.count {
            return true
        } else {
            return false
        }
    }
    
    func moveDown()->Bool {
        if !self.hasActions() && location.y != 0 {
            if let blockingCart = game.getCartAtLocation(CGPoint(x: location.x, y: location.y-1)) {
                if !blockingCart.moveDown() {
                    return false
                }
            }
            location.y -= 1
            self.run(SKAction.move(by: CGVector(dx: 0, dy: -size), duration: 0.2))
            return true
        }
        return false
    }
    
    func moveRight()->Bool {
        if !self.hasActions() && (location.x != game.columns-1 || (location.x+1 == game.exitSquare.x && location.y == game.exitSquare.y && balls == ballPositions.count)) {
            if let blockingCart = game.getCartAtLocation(CGPoint(x: location.x+1, y: location.y)) {
                if !blockingCart.moveRight() {
                    return false
                }
            }
            location.x += 1
            self.run(SKAction.move(by: CGVector(dx: size, dy: 0), duration: 0.2), completion: {
                if self.location.x == self.game.columns {
                    self.removeFromParent()
                    self.game.carts.remove(at: self.game.carts.index(of: self)!)
                    if soundEnabled {
                        self.run(SKAction.playSoundFileNamed("ding.wav", waitForCompletion: false))
                    }
                    self.game.score += 1
                    self.game.scoreLabel.text = "Score: \(self.game.score)"
                }
            })
            return true
        }
        return false
    }
    
    func moveLeft()->Bool {
        if !self.hasActions() && location.x != 0 {
            if let blockingCart = game.getCartAtLocation(CGPoint(x: location.x-1, y: location.y)) {
                if !blockingCart.moveLeft() {
                    return false
                }
            }
            location.x -= 1
            self.run(SKAction.move(by: CGVector(dx: -size, dy: 0), duration: 0.2))
            return true
        }
        return false
    }
    
    func addBallToCart(_ ballPos: CGPoint) {
        let ball = SKShapeNode(circleOfRadius: game.cartSize/8)
        ball.fillColor = self.fillColor
        ball.strokeColor = SKColor.black
        ball.zPosition = 1
        ball.position = self.convert(ballPos, from: self.game)
        let endPos = ballPositions[balls]
        ball.run(SKAction.move(to: endPos, duration: abs(Double(hypot(endPos.x - ball.frame.midX, endPos.y - ball.frame.midY)))/100))
        self.addChild(ball)
        balls += 1
    }
}
