//
//  GameScene.swift
//  Snake
//
//  Created by fordlabs on 13/09/19.
//  Copyright © 2019 fordlabs. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameScene: SKScene {
    
    var gameLogo: SKLabelNode!
    var bestScore: SKLabelNode!
    var playButton: SKShapeNode!
    
    var currentScore: SKLabelNode!
    var gameBackGround: SKShapeNode!
    var gameCell: [(node: SKShapeNode,x: Int, y: Int)] = []
    var playerPosition: [(Int,Int)] = []
    
    var scorePosition: CGPoint?
    
    
    var gameManager: GameManager!
    
    override func didMove(to view: SKView) {
        initializeMenu()
        gameManager = GameManager(scene: self)
        initializeGameView()
        
        let leftSwipeRecognizer:UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(leftSwipe))
        leftSwipeRecognizer.direction = .left
        view.addGestureRecognizer(leftSwipeRecognizer)
        
        let rightSwipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(rightSwipe))
        rightSwipeRecognizer.direction = .right
        view.addGestureRecognizer(rightSwipeRecognizer)
        
        let upSwipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(upSwipe))
        upSwipeRecognizer.direction = .up
        view.addGestureRecognizer(upSwipeRecognizer)
        
        let downSwipeRecognizer: UISwipeGestureRecognizer = UISwipeGestureRecognizer(target: self, action: #selector(downSwipe))
        downSwipeRecognizer.direction = .down
        view.addGestureRecognizer(downSwipeRecognizer)
    }

    @objc func leftSwipe() {
        gameManager.swipe(swapDirection: .left)
    }
    
    @objc func rightSwipe() {
        gameManager.swipe(swapDirection: .right)
    }
    
    @objc func upSwipe() {
        gameManager.swipe(swapDirection: .up)
    }
    
    @objc func downSwipe() {
        gameManager.swipe(swapDirection: .down)
    }
    
    private func initializeMenu() {
        gameLogoConstraints()
        bestScoreConstraints()
        playButtonConstraints() 
    }
    
    private func gameLogoConstraints() {
        gameLogo = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        gameLogo.zPosition = 1
        gameLogo.position = CGPoint(x: 0, y: (frame.size.height/2) - 200)
        gameLogo.text = "SNAKE"
        gameLogo.fontSize = 100
        gameLogo.fontColor = .yellow
        self.addChild(gameLogo)
    }
    
    private func bestScoreConstraints() {
        bestScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        bestScore.zPosition = 1
        bestScore.position = CGPoint(x: 0, y: gameLogo.position.y - 50)
        bestScore.fontSize = 40
        bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
        bestScore.fontColor = SKColor.white
        self.addChild(bestScore)
    }
    
    func playButtonConstraints() {
        playButton = SKShapeNode()
        playButton.name = "play_button"
        playButton.zPosition=1
        playButton.position = CGPoint(x:0, y: (frame.size.height / -2) + 200)
        playButton.fillColor = SKColor.cyan
        let topCorner = CGPoint(x: -50, y: 50)
        let bottomCorner = CGPoint(x: -50, y: -50)
        let middle = CGPoint(x: 50, y: 0)
        let path = CGMutablePath()
        path.addLine(to: topCorner)
        path.addLines(between: [topCorner, bottomCorner, middle])
        playButton.path = path
        self.addChild(playButton)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        gameManager.update(time: currentTime)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            let location = touch.location(in: self)
            let touchedNode = self.nodes(at: location)
            for node in touchedNode {
                if (node.name == "play_button") {
                    startGame()
                }
            }
        }
    }
    
    private func startGame() {
        print("startGame")
        gameLogo.run(SKAction.move(by: CGVector(dx: -50, dy: 600), duration: 0.5)) {
         self.gameLogo.isHidden = true
        }
        playButton.run(SKAction.scale(to: 0, duration: 0.3)) {
            self.playButton.isHidden = true
        }
        
        bestScore.run(SKAction.move(to: CGPoint(x: 0, y: (frame.size.height / -2) + 20), duration: 0.4)) {
            self.currentScore.setScale(0)
            self.currentScore.isHidden = false
            self.currentScore.run(SKAction.scale(to: 1, duration: 0.4))
            self.gameBackGround.setScale(0)
            self.gameBackGround.isHidden = false
            self.gameBackGround.run(SKAction.scale(to: 1, duration: 0.4))
            
            self.gameManager.initGame()
        }
    }
    
    private func initializeGameView() {
        let width = frame.size.width - 220
        let height = width * 2
        
        currentScoreConstraints()
        gameBackgroundConstraints(width: width, height: height)
        createGameBoard(width: width, height: height)
    }
    
    private func currentScoreConstraints() {
        currentScore = SKLabelNode(fontNamed: "ArialRoundedMTBold")
        currentScore.zPosition = 1
        currentScore.position = CGPoint(x: 0, y: (frame.size.height / -2) + 60)
        currentScore.fontSize = 40
        currentScore.isHidden = true
        currentScore.text = "Score: 0"
        currentScore.fontColor = SKColor.white
        self.addChild(currentScore)
    }
    
    func gameBackgroundConstraints(width: CGFloat, height: CGFloat) {
        let rect = CGRect(x: -width / 2, y: -height / 2, width: width, height: height)
        gameBackGround = SKShapeNode(rect: rect, cornerRadius: 0.02)
        gameBackGround.fillColor = SKColor.black
        gameBackGround.zPosition = 2
        gameBackGround.isHidden = true
        self.addChild(gameBackGround)
    }
    
    func createGameBoard(width: CGFloat, height: CGFloat) {
        let numCols = 20
        let numRows = numCols * 2
        let cellWidth: CGFloat = width / CGFloat(numCols)
        var x = CGFloat(width / -2) + (cellWidth / 2)
        var y = CGFloat(height / 2) - (cellWidth / 2)
        for i in 0...numRows - 1 {
            for j in 0...numCols - 1 {
                let cellNode = SKShapeNode(rectOf: CGSize(width: cellWidth, height: cellWidth))
                cellNode.strokeColor = .clear
                cellNode.zPosition = 2
                cellNode.position = CGPoint(x: x, y: y)
                gameCell.append((node: cellNode, x: i, y: j))
                gameBackGround.addChild(cellNode)
                x += cellWidth
            }
            x = CGFloat(width / -2) + (cellWidth / 2)
            y -= cellWidth
        }
    }
}
