//
//  GameScene.swift
//  Flappy Bird
//
//  Created by Hamada on 6/29/18.
//  Copyright © 2018 Hamada. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene , SKPhysicsContactDelegate {
    
   var bird = SKSpriteNode()
    var bg = SKSpriteNode()
    var pipe1 = SKSpriteNode()
    var pipe2 = SKSpriteNode()
    var scoreLabel = SKLabelNode()
    var score = 0
    var gameOverLabel = SKLabelNode()
    var timer = Timer()
    enum ColliderType : UInt32 {
        case Bird = 1
        case Object = 2
        case Gap = 4
    }
    var gameOver = false
    @objc func makePipes(){
        
        let movePipe = SKAction.move(by: CGVector(dx: -2 * self.frame.width, dy: 0), duration: TimeInterval(self.frame.width / 100))
        let removePipes = SKAction.removeFromParent()
        let moveAndRemovePipes = SKAction.sequence([movePipe,removePipes])
        let gapHeight = bird.size.height * 4
        let moveAmount = arc4random() % UInt32(self.frame.height / 2)
        let pipeOffset = CGFloat(moveAmount) - self.frame.height / 4
        
        let pipeTexture1 = SKTexture(imageNamed: "pipe1.png")
        
        pipe1 = SKSpriteNode(texture: pipeTexture1)
        pipe1.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeTexture1.size().height / 2 + gapHeight / 2 + pipeOffset)
        pipe1.run(moveAndRemovePipes)
        pipe1.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture1.size())
        pipe1.physicsBody!.isDynamic = false
        pipe1.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe1.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe1.zPosition = -1
        self.addChild(pipe1)
        let pipeTexture2 = SKTexture(imageNamed: "pipe2.png")
        pipe2 = SKSpriteNode(texture: pipeTexture2)
        pipe2.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY - pipeTexture2.size().height / 2 - gapHeight / 2 + pipeOffset)
        pipe2.run(moveAndRemovePipes)
        pipe2.physicsBody = SKPhysicsBody(rectangleOf: pipeTexture2.size())
        pipe2.physicsBody!.isDynamic = false
        pipe2.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        pipe2.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        pipe2.zPosition = -1
        self.addChild(pipe2)
        let gap = SKNode()
        gap.position = CGPoint(x: self.frame.midX + self.frame.width, y: self.frame.midY + pipeOffset)
        gap.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: pipeTexture1.size().width, height:gapHeight))
        gap.physicsBody!.isDynamic = false
        gap.run(moveAndRemovePipes)
        gap.physicsBody!.contactTestBitMask = ColliderType.Bird.rawValue
        gap.physicsBody!.categoryBitMask = ColliderType.Gap.rawValue
        gap.physicsBody!.collisionBitMask = ColliderType.Gap.rawValue
        self.addChild(gap)
    }
    func didBegin(_ contact: SKPhysicsContact) {
        if gameOver == false {
        if contact.bodyA.categoryBitMask == ColliderType.Gap.rawValue || contact.bodyB.categoryBitMask == ColliderType.Gap.rawValue{
            score+=1
            scoreLabel.text = String(score)
        }else{
        
        self.speed = 0
        gameOver = true
            timer.invalidate()
        gameOverLabel.fontName = "Helvetica"
            gameOverLabel.fontSize = 30
            gameOverLabel.text = "Game Over! , Tap to PLay Again"
            gameOverLabel.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
            self.addChild(gameOverLabel)
            }
        }
    }
    override func didMove(to view: SKView) {
        self.physicsWorld.contactDelegate = self
        setupGame()
       
        }
    func setupGame(){
        timer = Timer.scheduledTimer(timeInterval: 3, target: self, selector: #selector(self.makePipes), userInfo: nil, repeats: true)
        let bgTexture = SKTexture(imageNamed: "bg.png")
        
        let moveBGAnimation = SKAction.move(by: CGVector(dx: -bgTexture.size().width, dy: 0), duration: 7)
        let shiftBGAnimation = SKAction.move(by: CGVector(dx: bgTexture.size().width, dy: 0), duration: 0)
        let moveBGForever = SKAction.repeatForever(SKAction.sequence([moveBGAnimation,shiftBGAnimation]))
        var i : CGFloat = 0
        while i < 3 {
            bg = SKSpriteNode(texture: bgTexture)
            bg.run(moveBGForever)
            bg.position = CGPoint(x:  bgTexture.size().width * i, y: self.frame.midY)
            bg.size.height = self.frame.height
            bg.zPosition = -2 // background is always behind bird
            self.addChild(bg)
            
            i+=1
        }
        let birdTexture1 = SKTexture(imageNamed: "flappy1.png")
        let birdTexture2 = SKTexture(imageNamed: "flappy2.png")
        
        let animation = SKAction.animate(with: [birdTexture1 , birdTexture2], timePerFrame: 0.1)
        let makeBirdFlap = SKAction.repeatForever(animation)
        bird = SKSpriteNode(texture: birdTexture1)
        
        
        bird.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
        bird.run(makeBirdFlap)
        bird.physicsBody = SKPhysicsBody(circleOfRadius: birdTexture1.size().height/2)
        bird.physicsBody!.isDynamic = false
        bird.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        bird.physicsBody!.categoryBitMask = ColliderType.Bird.rawValue
        bird.physicsBody!.collisionBitMask = ColliderType.Bird.rawValue
        self.addChild(bird)
        let ground = SKNode()
        ground.position = CGPoint(x: self.frame.midX, y: -self.frame.height/2)
        ground.physicsBody = SKPhysicsBody(rectangleOf: CGSize(width: self.frame.width, height: 1))
        ground.physicsBody!.isDynamic=false
        ground.physicsBody!.contactTestBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.categoryBitMask = ColliderType.Object.rawValue
        ground.physicsBody!.collisionBitMask = ColliderType.Object.rawValue
        self.addChild(ground)
        scoreLabel.fontName = "Helvetica"
        scoreLabel.fontSize = 60
        scoreLabel.text = "0"
        scoreLabel.position = CGPoint(x: self.frame.midX, y: self.frame.height / 2 - 70)
        self.addChild(scoreLabel)
    }
        
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if gameOver == false {
        bird.physicsBody!.isDynamic = true
        bird.physicsBody!.velocity = CGVector(dx: 0, dy: 0)
        bird.physicsBody!.applyImpulse(CGVector(dx: 0, dy: 50))
        }else{
        gameOver = false
        score = 0
        self.speed = 1
        self.removeAllChildren()
            setupGame()
        }
        }
        
   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
    }
}
