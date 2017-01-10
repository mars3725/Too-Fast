//
//  GameScene.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/21/16.
//  Copyright (c) 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit
import GCHelper
import AVFoundation

class GameScene: SKScene {
    var grid = [[Int]]()
    let rows:CGFloat = 6
    let columns:CGFloat = 4
    let minBorderSpace:CGFloat = 25
    var cartSize = CGFloat()
    var gridSize = CGRect()
    var selectedCart:Cart?
    var carts = [Cart]()
    var balls = [SKShapeNode]()
    var spawnSquare = CGPoint(x: 0, y: 0)
    var spawnerIdentifier = SKShapeNode()
    var exitSquare = CGPoint(x: 0, y: 0)
    var exitIdentifier = SKShapeNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    var pauseButton = Button(imageNamed: "Pause")
    var utilityButton = Button(imageNamed: "Sound On")
    var moveAction = SKAction()
    var gamePaused = false
    var gameAudio = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Main", withExtension: "aiff")!)
    
    override func didMove(to view: SKView) {
        setup()
        
        let leftSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        leftSwipeGesture.direction = .left
        self.view!.addGestureRecognizer(leftSwipeGesture)
        
        let rightSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        rightSwipeGesture.direction = .right
        self.view!.addGestureRecognizer(rightSwipeGesture)

        
        let upSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        upSwipeGesture.direction = .up
        self.view!.addGestureRecognizer(upSwipeGesture)
        
        let downSwipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipe(_:)))
        downSwipeGesture.direction = .down
        self.view!.addGestureRecognizer(downSwipeGesture)
        
        let spawnAction = SKAction.run({
            if self.carts.count != Int(self.rows*self.columns) {
                if !self.gamePaused {
                    switch arc4random_uniform(4) {
                    case 0:
                        self.spawnCart(SKColor.red)
                    case 1:
                        self.spawnCart(SKColor.yellow)
                    case 2:
                        self.spawnCart(SKColor.green)
                    case 3:
                        self.spawnCart(SKColor.blue)
                    default:
                        print("shouldn't be here")
                    }
                }
            } else {
                GCHelper.sharedInstance.reportLeaderboardIdentifier("highscores", score: self.score)
                self.view?.presentScene(MenuScene(size: self.size), transition: SKTransition.crossFade(withDuration: 0.5))
            }
        })
        let waitAction = SKAction.wait(forDuration: 5, withRange: 2)
        self.run(SKAction.repeatForever(SKAction.sequence([spawnAction, waitAction])))
        
        let spawnerWaitAction = SKAction.wait(forDuration: 15, withRange: 5)
        let moveSequence = SKAction.run({
            if !self.gamePaused {
                self.moveSpawner()
                self.moveExit()
            }
        })
        moveAction = SKAction.repeatForever(SKAction.sequence([spawnerWaitAction, moveSequence]))
        self.run(moveAction, withKey: "moveAction")
        
        let ballwaitAction = SKAction.wait(forDuration: 2, withRange: 1)
        let spawnBallAction = SKAction.run({
            if !self.gamePaused {
                switch arc4random_uniform(4) {
                case 0:
                    self.spawnBall(SKColor.red)
                case 1:
                    self.spawnBall(SKColor.yellow)
                case 2:
                    self.spawnBall(SKColor.green)
                case 3:
                    self.spawnBall(SKColor.blue)
                default:
                    print("shouldn't be here")
                }
            }
        })
        self.run(SKAction.repeatForever(SKAction.sequence([ballwaitAction, spawnBallAction])))
    }
    
    func handleSwipe(_ sender: UISwipeGestureRecognizer) {
        if selectedCart != nil {
            switch sender.direction {
            case UISwipeGestureRecognizerDirection.up:
                selectedCart!.moveUp()
            case UISwipeGestureRecognizerDirection.down:
                selectedCart!.moveDown()
            case UISwipeGestureRecognizerDirection.left:
                selectedCart!.moveLeft()
            case UISwipeGestureRecognizerDirection.right:
                selectedCart!.moveRight()
            default:
                print("shouldn't be here")
            }
            selectedCart = nil
        }
    }
    
    func setup() {
        self.backgroundColor = SKColor.white
        
        let gameFader = iiFaderForAvAudioPlayer(player: gameAudio)
        gameAudio.numberOfLoops = -1
        gameAudio.volume = 0
        gameAudio.play()
        
        if soundEnabled {
            gameFader.fadeIn(1, velocity: 2, onFinished: nil)
        }
        
        let maxWidth = self.size.width - minBorderSpace * 2
        let maxHeight = self.size.height - (minBorderSpace * 2 + 150)
        cartSize = min(maxWidth/CGFloat(columns), maxHeight/CGFloat(rows))
        
        let actualHeight = cartSize * rows
        let actualWidth = cartSize * columns
        gridSize = CGRect(x: (self.size.width - actualWidth)/2, y: self.size.height - (actualHeight + minBorderSpace), width: actualWidth, height: actualHeight)
        grid = Array(repeating: Array(repeating: 0, count: Int(columns)), count: Int(rows))
        
        let background = SKShapeNode(rect: gridSize)
        background.fillColor = SKColor.lightGray
        background.strokeColor = SKColor.clear
        background.alpha = 0.8
        background.zPosition = zLayers.background.rawValue
        self.addChild(background)
        
        for index in 1...grid.first!.count-1 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: gridSize.origin.x + cartSize*CGFloat(index), y: gridSize.origin.y))
            path.addLine(to: CGPoint(x: gridSize.origin.x + cartSize*CGFloat(index), y: gridSize.maxY))
            let line = SKShapeNode(path: path)
            line.strokeColor = SKColor.darkGray
            line.zPosition = zLayers.gridLines.rawValue
            self.addChild(line)
        }
        
        for index in 1...grid.count-1 {
            let path = CGMutablePath()
            path.move(to: CGPoint(x: gridSize.origin.x, y: gridSize.origin.y + cartSize*CGFloat(index)))
            path.addLine(to: CGPoint(x: gridSize.maxX, y: gridSize.origin.y + cartSize*CGFloat(index)))
            let line = SKShapeNode(path: path)
            line.strokeColor = SKColor.darkGray
            line.zPosition = zLayers.gridLines.rawValue
            self.addChild(line)
        }
        
        let border = SKShapeNode(rect: gridSize)
        border.fillColor = SKColor.clear
        border.strokeColor = SKColor.darkGray
        border.lineWidth = 7
        border.zPosition = zLayers.border.rawValue
        self.addChild(border)
        
        let leftWhiteSpace = SKShapeNode(rectOf: CGSize(width: gridSize.minX, height: self.size.height))
        leftWhiteSpace.position = CGPoint(x: leftWhiteSpace.frame.width/2, y: self.size.height/2)
        leftWhiteSpace.fillColor = SKColor.white
        leftWhiteSpace.strokeColor = SKColor.white
        leftWhiteSpace.zPosition = zLayers.whiteSpace.rawValue
        self.addChild(leftWhiteSpace)
        
        let rightWhiteSpace = SKShapeNode(rectOf: CGSize(width: gridSize.minX, height: self.size.height))
        rightWhiteSpace.position = CGPoint(x: self.size.width - rightWhiteSpace.frame.width/2, y: self.size.height/2)
        rightWhiteSpace.fillColor = SKColor.white
        rightWhiteSpace.strokeColor = SKColor.white
        rightWhiteSpace.zPosition = zLayers.whiteSpace.rawValue
        self.addChild(rightWhiteSpace)
        
        let topWhiteSpace = SKShapeNode(rectOf: CGSize(width: self.size.width, height: minBorderSpace))
        topWhiteSpace.position = CGPoint(x: self.size.width/2, y: self.size.height - minBorderSpace/2)
        topWhiteSpace.fillColor = SKColor.white
        topWhiteSpace.strokeColor = SKColor.white
        topWhiteSpace.zPosition = zLayers.whiteSpace.rawValue
        self.addChild(topWhiteSpace)
        
        let bottomWhiteSpace = SKShapeNode(rectOf: CGSize(width: self.size.width, height: gridSize.origin.y))
        bottomWhiteSpace.position = CGPoint(x: self.size.width/2, y: gridSize.minY/2)
        bottomWhiteSpace.fillColor = SKColor.white
        bottomWhiteSpace.strokeColor = SKColor.white
        bottomWhiteSpace.zPosition = zLayers.whiteSpace.rawValue
        self.addChild(bottomWhiteSpace)
        
        scoreLabel.fontName = appFont
        scoreLabel.fontColor = SKColor.darkGray
        scoreLabel.fontSize = 40
        scoreLabel.text = "Score: 0"
        scoreLabel.position = CGPoint(x: self.size.width/2, y: gridSize.minY/2 + scoreLabel.frame.height/2)
        scoreLabel.zPosition = zLayers.uiElements.rawValue
        self.addChild(scoreLabel)
        
        spawnerIdentifier.strokeColor = SKColor.green
        spawnerIdentifier.lineWidth = 10
        spawnerIdentifier.zPosition = zLayers.spawners.rawValue
        let spawnPath = CGMutablePath()
        spawnSquare = CGPoint(x: -1, y: floor(rows/2))
        spawnPath.move(to: CGPoint(x: gridSize.origin.x, y: gridSize.origin.y + cartSize*floor(rows/2)))
        spawnPath.addLine(to: CGPoint(x: gridSize.origin.x, y: gridSize.origin.y + cartSize*(floor(rows/2) + 1)))
        spawnerIdentifier.path = spawnPath
        self.addChild(spawnerIdentifier)
        
        exitIdentifier.strokeColor = SKColor.red
        exitIdentifier.lineWidth = 10
        exitIdentifier.zPosition = zLayers.spawners.rawValue
        let exitPath = CGMutablePath()
        exitSquare = CGPoint(x: CGFloat(columns), y: floor(rows/2))
        exitPath.move(to: CGPoint(x: gridSize.origin.x + cartSize*CGFloat(columns),y: gridSize.origin.y + cartSize*floor(rows/2)))
        exitPath.addLine(to: CGPoint(x: gridSize.origin.x + cartSize*CGFloat(columns), y: gridSize.origin.y + cartSize*(floor(rows/2)+1)))
        exitIdentifier.path = exitPath
        self.addChild(exitIdentifier)
        
        pauseButton.position = CGPoint(x: pauseButton.frame.width/2 + gridSize.minX, y: gridSize.minY/2 + pauseButton.frame.height/2)
        pauseButton.zPosition = zLayers.uiElements.rawValue
        self.addChild(pauseButton)
        pauseButton.tapAction = SKAction.run({
            if self.gamePaused {
                self.togglePause(false)
                self.pauseButton.setImage(named: "Pause")
                if soundEnabled {
                    self.utilityButton.setImage(named: "Sound On")
                } else {
                    self.utilityButton.setImage(named: "Sound Off")
                }
            } else {
                self.togglePause(true)
                self.pauseButton.setImage(named: "Play")
                self.utilityButton.setImage(named: "Quit")
            }
        })
        
        if !soundEnabled {
            utilityButton.setImage(named: "Sound Off")
        }
        utilityButton.position = CGPoint(x: gridSize.maxX - utilityButton.frame.width/2, y: gridSize.minY/2 + utilityButton.frame.height/2)
        utilityButton.zPosition = zLayers.uiElements.rawValue
        self.addChild(utilityButton)
        utilityButton.tapAction = SKAction.run({
            if self.gamePaused {
                self.gameAudio.stop()
                self.view!.presentScene(MenuScene(size: self.size), transition: SKTransition.crossFade(withDuration: 0.5))
            } else {
                if soundEnabled {
                    soundEnabled = false
                    self.gameAudio.pause()
                    self.utilityButton.setImage(named: "Sound Off")
                } else {
                    soundEnabled = true
                    self.gameAudio.volume = 1
                    self.gameAudio.play()
                    self.utilityButton.setImage(named: "Sound On")
                }
            }
            UserDefaults.standard.set(soundEnabled, forKey: "soundEnabled")
        })
    }
    
    func togglePause(_ shouldPause: Bool) {
        if shouldPause {
            gamePaused = true
            for cart in carts {
                cart.isPaused = true
            }
            for ball in balls {
                ball.isPaused = true
            }
        } else {
            gamePaused = false
            for cart in carts {
                cart.isPaused = false
            }
            for ball in balls {
                ball.isPaused = false
            }
        }
    }
    
    func spawnCart(_ color: SKColor) {
        let cart = Cart(game: self, color: color)
        if spawnSquare.x == -1 {
            cart.position = CGPoint(x: gridSize.minX - cartSize, y: gridSize.minY + cartSize*spawnSquare.y)
            cart.location = CGPoint(x: -1, y: spawnSquare.y)
            self.addChild(cart)
            carts.append(cart)
            
            if !cart.moveRight() {
                cart.removeFromParent()
                carts.remove(at: carts.index(of: cart)!)
                self.removeAction(forKey: "moveAction")
                moveSpawner()
                self.run(moveAction, withKey: "moveAction")
                
            }
        } else {
            cart.position = CGPoint(x: gridSize.minX + cartSize*spawnSquare.x, y: gridSize.minY - cartSize)
            cart.location = CGPoint(x: spawnSquare.x, y: -1)
            self.addChild(cart)
            carts.append(cart)
            
            if !cart.moveUp() {
                cart.removeFromParent()
                carts.remove(at: carts.index(of: cart)!)
                self.removeAction(forKey: "moveAction")
                moveSpawner()
                self.run(moveAction, withKey: "moveAction")
            }
        }
    }
    
    func spawnBall(_ color: SKColor) {
        let ball = Ball(color: color, diameter: cartSize/4)
        var endPoint = CGPoint()
        
        let int:UInt32 = 5
        let randVal = CGFloat(arc4random_uniform(int))
        
        print(randVal)
        
        switch arc4random_uniform(4) {
        case 0:
            ball.position = CGPoint(x: gridSize.origin.x + CGFloat(arc4random_uniform(UInt32(gridSize.width - ball.frame.width))), y: gridSize.maxY)
            endPoint = CGPoint(x: ball.position.x, y: gridSize.minY - ball.frame.height)
            ball.run(SKAction.move(to: endPoint, duration: Double(ball.position.y - endPoint.y)/50), completion: {
                ball.removeFromParent()
                self.balls.remove(at: self.balls.index(of: ball)!)
            })
        case 1:
            ball.position = CGPoint(x: gridSize.origin.x + CGFloat(arc4random_uniform(UInt32(gridSize.width - ball.frame.width))), y: gridSize.minY - ball.frame.height)
            endPoint = CGPoint(x: ball.position.x, y: gridSize.maxY)
            ball.run(SKAction.move(to: endPoint, duration: Double(endPoint.y - ball.position.y)/50), completion: {
                ball.removeFromParent()
                self.balls.remove(at: self.balls.index(of: ball)!)
            })
            
        case 2:
            ball.position = CGPoint(x: gridSize.minX - ball.frame.width, y: gridSize.minY + CGFloat(arc4random_uniform(UInt32(gridSize.height - ball.frame.height))))
            endPoint = CGPoint(x: gridSize.maxX, y: ball.position.y)
            ball.run(SKAction.move(to: endPoint, duration: Double(endPoint.x - ball.position.x)/50), completion: {
                ball.removeFromParent()
                self.balls.remove(at: self.balls.index(of: ball)!)
            })
        case 3:
            ball.position = CGPoint(x: gridSize.maxX, y: gridSize.minY + CGFloat(arc4random_uniform(UInt32(gridSize.height - ball.frame.height))))
            endPoint = CGPoint(x: gridSize.minX - ball.frame.width, y: ball.position.y)
            ball.run(SKAction.move(to: endPoint, duration: Double(ball.position.x - endPoint.x)/50), completion: {
                ball.removeFromParent()
                self.balls.remove(at: self.balls.index(of: ball)!)
            })
        default:
            print("shouldn't be here")
        }
        self.addChild(ball)
        balls.append(ball)
    }
    
    func moveSpawner() {
        spawnerIdentifier.run(SKAction.fadeOut(withDuration: 0.25), completion: {
            let path = CGMutablePath()
            if arc4random_uniform(2) == 0 {
                let randCol = arc4random_uniform(UInt32(self.columns))
                self.spawnSquare = CGPoint(x: CGFloat(randCol), y: -1)
                path.move(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(randCol),y: self.gridSize.origin.y))
                path.addLine(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(randCol + 1), y: self.gridSize.origin.y))
            } else {
                let randRow = arc4random_uniform(UInt32(self.rows))
                self.spawnSquare = CGPoint(x: -1, y: CGFloat(randRow))
                path.move(to: CGPoint(x: self.gridSize.origin.x, y: self.gridSize.origin.y + self.cartSize*CGFloat(randRow)))
                path.addLine(to: CGPoint(x: self.gridSize.origin.x, y: self.gridSize.origin.y + self.cartSize*CGFloat(randRow + 1)))
            }
            self.spawnerIdentifier.path = path
            self.spawnerIdentifier.run(SKAction.fadeIn(withDuration: 0.25))
        })
    }
    
    func moveExit() {
        exitIdentifier.run(SKAction.fadeOut(withDuration: 0.25), completion: {
            let path = CGMutablePath()
            if arc4random_uniform(2) == 0 {
                let randCol = arc4random_uniform(UInt32(self.columns))
                self.exitSquare = CGPoint(x: CGFloat(randCol), y: CGFloat(self.rows))
                path.move(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(randCol), y: self.gridSize.origin.y + self.cartSize*CGFloat(self.rows)))
                path.addLine(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(randCol + 1), y: self.gridSize.origin.y + self.cartSize*CGFloat(self.rows)))
            } else {
                let randRow = arc4random_uniform(UInt32(self.rows))
                self.exitSquare = CGPoint(x: CGFloat(self.columns), y: CGFloat(randRow))
                path.move(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(self.columns), y: self.gridSize.origin.y + self.cartSize*CGFloat(randRow)))
                path.addLine(to: CGPoint(x: self.gridSize.origin.x + self.cartSize*CGFloat(self.columns), y: self.gridSize.origin.y + self.cartSize*CGFloat(randRow + 1)))
            }
            self.exitIdentifier.path = path
            self.exitIdentifier.run(SKAction.fadeIn(withDuration: 0.25))
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            if !gamePaused {
                for cart in carts {
                    if cart.contains(location) {
                        selectedCart = cart
                    }
                }
            }
        }
    }
    
    func getCartAtLocation(_ position: CGPoint)->Cart? {
        for cart in carts {
            if cart.location.x == position.x && cart.location.y == position.y {
                return cart
            }
        }
        return nil
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedCart = nil
    }
    
    override func update(_ currentTime: TimeInterval) {
        if backgroundPause {
            togglePause(true)
            pauseButton.setImage(named: "Play")
            backgroundPause = false
        }
        
        for cart  in carts {
            for ball in balls {
                if cart.contains(CGPoint(x: ball.frame.midX, y: ball.frame.midY)) && ball.fillColor == cart.fillColor && cart.balls < cart.ballPositions.count {
                    ball.removeFromParent()
                    self.balls.remove(at: self.balls.index(of: ball)!)
                    cart.addBallToCart(CGPoint(x: ball.frame.midX, y: ball.frame.midY))
                }
            }
        }
    }
}

enum zLayers: CGFloat {
    case background = 1
    case gridLines = 2
    case carts = 3
    case balls = 4
    //case collectedBalls = 5
    case whiteSpace = 6
    case border = 7
    case spawners = 8
    case uiElements = 9
}
