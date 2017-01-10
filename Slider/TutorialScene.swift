//
//  TutorialScene.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/28/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit
import GCHelper

class TutorialScene: GameScene {
    var tutorialStage = 0
    var shouldAdvanceStage = false
    var advancementAllowed = false
    var textBox = SKMultilineLabel(text: "I was told that this game is confusing without instructions so here's a quick tutorial. Tap to begin.", labelWidth: 300, pos: CGPoint.zero, fontName: appFont, fontSize: 20, fontColor: SKColor.darkGray, leading: 18, alignment: .center, shouldShowBox: true)
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        removeAllActions()
        
        textBox.pos = CGPoint(x: gridSize.midX, y: gridSize.midY - 100)
        textBox.zPosition = zLayers.uiElements.rawValue
        self.addChild(textBox)
    }
    
    func changeText(_ newText: String) {
        
        textBox.run(SKAction.fadeOut(withDuration: 0.25), completion: {
            self.textBox.text = newText
            self.textBox.update()
            self.textBox.run(SKAction.fadeIn(withDuration: 0.25))
            
        })
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let location = touches.first!.location(in: self)
        
        if (tutorialStage < 3 || tutorialStage > 7) && !pauseButton.contains(location) && !utilityButton.contains(location) {
            shouldAdvanceStage = true
        }
        
        if tutorialStage == 13 {
            gameAudio.stop()
            self.view!.presentScene(MenuScene(size: self.size), transition: SKTransition.crossFade(withDuration: 0.5))
        }
        
        super.touchesBegan(touches, with: event)
    }
    
    override func update(_ currentTime: TimeInterval) {
        if shouldAdvanceStage {
            switch tutorialStage {
            case 0:
                changeText("To pause the game, press the button in the bottom left of the screen. Press it again to unpause. The button in the bottom right will toggle sound or quit the game depending on whether it is paused.")
            case 1:
                changeText("Blocks will spawn from the green line on the left or bottom of the grid.")
                spawnCart(SKColor.red)
            case 2:
                changeText("Swipe the blocks up, down, left, or right to move them. Try it now.")
            case 3:
                changeText("Good! Collect balls of the same color as the block. To make it easy, I'll make them all red for now.")
                let sequence = SKAction.sequence([SKAction.run({self.spawnBall(SKColor.red)}), SKAction.wait(forDuration: 2.5)])
                self.run(SKAction.repeatForever(sequence), withKey: "spawnBalls")
            case 4:
                changeText("Ok...now collect three more.")
            case 5:
                changeText("Great! Now move the block to the red line on the right or top of the grid.")
                self.removeAction(forKey: "spawnBalls")
            case 6:
                changeText("Cool, you're there. Swipe the full block into the red line to score points.")
            case 7:
                changeText("All blocks are spawned from the green line and can be cleared by swiping them into the red line reguardless of the block's color. You can only clear blocks that are holding four balls.")
            case 8:
                changeText("Occasionally, the block entrance and exit will move.")
                moveSpawner()
                moveExit()
            case 9:
                changeText("Blocks will only spawn if there is room in the row or column. Once a block fails to spawn, the green and red line will relocate.")
                let wait = SKAction.wait(forDuration: 0.25)
                let sequence = SKAction.sequence([SKAction.run({self.spawnCart(SKColor.yellow)}), wait, SKAction.run({self.spawnCart(SKColor.green)}), wait, SKAction.run({self.spawnCart(SKColor.blue)}), wait, SKAction.run({self.spawnCart(SKColor.red)}), wait, SKAction.run({self.spawnCart(SKColor.yellow)}), wait, SKAction.run({self.spawnCart(SKColor.green)})])
                self.run(sequence)
            case 10:
                changeText("You lose when a block tries to spawn while the grid is entirely filled.")
                moveSpawner()
                moveExit()
            case 11:
                changeText("Your high score is automatically posted to the leaderboard at the end of every game.")
            case 12:
                changeText("Thats all. Now have fun playing my game! 🎮")
            default:
                break
            }
            advancementAllowed = false
            shouldAdvanceStage = false
            tutorialStage += 1
            self.run(SKAction.wait(forDuration: 1), completion: {self.advancementAllowed = true})
        } else {
            if advancementAllowed && metSpecialCondition(tutorialStage) {
                shouldAdvanceStage = true
            }
        }
        
        super.update(currentTime)
    }
    
    func metSpecialCondition(_ stage: Int)-> Bool {
        switch stage {
        case 3:
            if carts.first?.location != CGPoint(x: spawnSquare.x + 1, y: spawnSquare.y) {
                return true
            }
        case 4:
            if carts.first?.balls == 1 {
                return true
            }
        case 5:
            if carts.first?.balls == 4 {
                return true
            }
        case 6:
            if carts.first?.location == CGPoint(x: exitSquare.x-1, y: exitSquare.y) {
                return true
            }
        case 7:
            if carts.count == 0 {
                return true
            }
        default:
            break
        }
        return false
    }
}
