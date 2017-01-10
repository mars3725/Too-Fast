//
//  MenuScene.swift
//  Too Fast!
//
//  Created by Matthew Mohandiss on 8/23/16.
//  Copyright © 2016 Matthew Mohandiss. All rights reserved.
//

import SpriteKit
import GCHelper
import AVFoundation

class MenuScene: SKScene {
    var leaderboardsButton = Button(imageNamed: "Leaderboard")
    var helpButton = Button(imageNamed: "Help")
    var playButton = Button(imageNamed: "Play")
    var socialButton = Button(imageNamed: "Social")
    let titleAudio = try! AVAudioPlayer(contentsOf: Bundle.main.url(forResource: "Title", withExtension: "aiff")!)
    
    override func didMove(to view: SKView) {
        backgroundColor = SKColor.white
        
        let titleFader = iiFaderForAvAudioPlayer(player: titleAudio)
        titleAudio.numberOfLoops = -1
        titleAudio.volume = 0
        titleAudio.play()
        
        if soundEnabled {
            titleFader.fadeIn(1, velocity: 2, onFinished: nil)
        }
        
        let titleLabel = SKLabelNode()
        titleLabel.text = "Too Fast!"
        titleLabel.fontName = appFont
        titleLabel.fontColor = SKColor.darkGray
        titleLabel.position = CGPoint(x: self.size.width/2, y: self.size.height/2 + 25)
        titleLabel.alpha = 0
        titleLabel.run(SKAction.fadeAlpha(to: 1, duration: 1))
        self.addChild(titleLabel)
        
        let fontScale = (self.size.width * (2/3))/titleLabel.frame.width
        titleLabel.fontSize *= fontScale
        
        let underline = SKSpriteNode(color: SKColor.darkGray, size: CGSize(width: 0, height: 5))
        underline.anchorPoint = CGPoint.zero
        underline.position = CGPoint(x: titleLabel.frame.minX, y: titleLabel.frame.minY - 10)
        self.run(SKAction.wait(forDuration: 1), completion: {
            underline.run(SKAction.resize(toWidth: titleLabel.frame.width, duration: 0.75))
        })
        self.addChild(underline)
        
        leaderboardsButton.position = CGPoint(x: self.size.width/2 - 135, y: -leaderboardsButton.frame.height/2)
        self.run(SKAction.wait(forDuration: 0), completion: {
            self.leaderboardsButton.run(SKAction.move(to: CGPoint(x: self.size.width/2 - 135, y: self.size.height/2 - 150), duration: 1))
        })
        leaderboardsButton.tapAction = SKAction.run({
            GCHelper.sharedInstance.showGameCenter(self.view!.window!.rootViewController!, viewState: .leaderboards)
        })
        self.addChild(leaderboardsButton)
        
        helpButton.position = CGPoint(x: self.size.width/2 - 45, y: -helpButton.frame.height/2)
        self.run(SKAction.wait(forDuration: 0.25), completion: {
            self.helpButton.run(SKAction.move(to: CGPoint(x: self.size.width/2 - 45, y: self.size.height/2 - 150), duration: 1))
        })
        helpButton.tapAction = SKAction.run({
            self.titleAudio.stop()
            self.view!.presentScene(TutorialScene(size: self.size), transition: SKTransition.crossFade(withDuration: 0.5))
        })
        self.addChild(helpButton)
        
        playButton.position = CGPoint(x: self.size.width/2 + 45, y: -playButton.frame.height/2)
        self.run(SKAction.wait(forDuration: 0.5), completion: {
            self.playButton.run(SKAction.move(to: CGPoint(x: self.size.width/2 + 45, y: self.size.height/2 - 150), duration: 1))
        })
        playButton.tapAction = SKAction.run({
            self.titleAudio.stop()
            self.view!.presentScene(GameScene(size: self.size), transition: SKTransition.crossFade(withDuration: 0.5))
        })
        self.addChild(playButton)
        
        socialButton.position = CGPoint(x: self.size.width/2 + 135, y: -socialButton.frame.height/2)
        self.run(SKAction.wait(forDuration: 0.75), completion: {
            self.socialButton.run(SKAction.move(to: CGPoint(x: self.size.width/2 + 135, y: self.size.height/2 - 150), duration: 1))
        })
        socialButton.tapAction = SKAction.run({
            UIApplication.shared.openURL(URL(string:
                "itms-apps://itunes.apple.com/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=1148458363&onlyLatestVersion=true&pageNumber=0&sortOrdering=1&type=Purple+Software")!)
        })
        self.addChild(socialButton)
    }
}
