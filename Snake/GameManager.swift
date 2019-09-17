//
//  GameManager.swift
//  Snake
//
//  Created by fordlabs on 13/09/19.
//  Copyright © 2019 fordlabs. All rights reserved.
//

import SpriteKit

class GameManager {
    var scene: GameScene
    
    var nextTime: Double?
    var timeExtension: Double = 0.15
    
    var playerDirection: PlayerDirection = .down
    var currentScore: Int = 0
    init(scene: GameScene) {
        self.scene = scene
    }
    
    func initGame() {
        scene.playerPosition.append((12, 11))
        scene.playerPosition.append((11, 11))
        scene.playerPosition.append((10, 11))
        renderChange()
        generateNewPoint()
    }
    
    func generateNewPoint() {
        var xPoint = CGFloat(arc4random_uniform(19))
        var yPoint = CGFloat(arc4random_uniform(39))
        
        while contains(a: scene.playerPosition, v: (Int(xPoint), Int(yPoint))) {
            xPoint = CGFloat(arc4random_uniform(19))
            yPoint = CGFloat(arc4random_uniform(39))
        }
        
        scene.scorePosition = CGPoint(x: xPoint, y: yPoint)
    }
    
    private func renderChange() {
        for (node, x, y)  in scene.gameCell {
            if contains(a: scene.playerPosition, v: (x,y)) {
                node.fillColor = SKColor.cyan
            } else {
                node.fillColor = SKColor.clear
                if scene.scorePosition != nil {
                    if Int((scene.scorePosition?.x)!) == y && Int((scene.scorePosition?.y)!) == x {
                        node.fillColor = SKColor.red
                    }
                }
            }
        }
    }
    
    private func contains(a: [(Int,Int)], v: (Int, Int)) -> Bool{
        let (c1, c2) = v
        for (v1, v2) in a {
            if v1 == c1 && v2 == c2 {
                return true
            }
        }
        return false
    }
    
    
    func update(time: Double) {
        guard let nTime = nextTime else { return nextTime = time + timeExtension }
        if time >= nTime {
            nextTime = time + timeExtension
            updatePlayerPosition()
            checkForScore()
            checkForDeath()
            finishAnimation()
        }
    }
    
    private func checkForScore() {
        if scene.scorePosition != nil {
            let x = scene.playerPosition[0].0
            let y = scene.playerPosition[0].1
            if Int((scene.scorePosition?.x)!) == y && Int((scene.scorePosition?.y)!) == x {
                currentScore += 1
                scene.currentScore.text = "Score: \(currentScore)"
                generateNewPoint()
                scene.playerPosition.append(scene.playerPosition.last!)
            }
        }
    }
    
    
    func swipe(swapDirection: PlayerDirection) {
        if !(swapDirection == .down && playerDirection == .up) && !(swapDirection == .up && playerDirection == .down) {
            if !(swapDirection == .left && playerDirection == .right) && !(swapDirection == .right && playerDirection == .left) {
                if playerDirection != .dead {
                    playerDirection = swapDirection
                }
            }
        }
    }
    
    private func updatePlayerPosition() {
        var xChange = -1
        var yChange = 0
        
        switch playerDirection {
        case .left:
            xChange = -1
            yChange = 0
            break
        case .right:
            xChange = 1
            yChange = 0
            break
        case .up:
            xChange = 0
            yChange = -1
            break
        case .down:
            xChange = 0
            yChange = 1
            break
        case .dead:
            xChange = 0
            yChange = 0
            break
        }
        if scene.playerPosition.count > 0 {
            var startPosition = scene.playerPosition.count - 1
            while startPosition > 0 {
                scene.playerPosition[startPosition] = scene.playerPosition[startPosition - 1]
                startPosition = startPosition - 1
            }
            scene.playerPosition[0] = (scene.playerPosition[0].0 + yChange, scene.playerPosition[0].1 + xChange)
        }
        if scene.playerPosition.count > 0 {
            let x = scene.playerPosition[0].1
            let y = scene.playerPosition[0].0
            if y > 40 {
                scene.playerPosition[0].0 = 0
            } else if y < 0 {
                scene.playerPosition[0].0 = 40
            } else if x > 20 {
                scene.playerPosition[0].1 = 0
            } else if x < 0 {
                scene.playerPosition[0].1 = 20
            }
        }
        
        renderChange()
    }
    
    private func checkForDeath() {
        if scene.playerPosition.count > 0 {
            var arrayOfPositions = scene.playerPosition
            let headOfSnake = arrayOfPositions[0]
            print("HeadSnake -> \(headOfSnake)")
            arrayOfPositions.remove(at: 0)
            if contains(a: arrayOfPositions, v: headOfSnake) {
                playerDirection = .dead
            }
        }
    }
    
    func finishAnimation() {
        if playerDirection == .dead && scene.playerPosition.count > 0 {
            var hasFinished = true
            let headOfSnake = scene.playerPosition[0]
            for position in scene.playerPosition {
                if headOfSnake != position {
                    hasFinished = false
                }
            }
            if hasFinished {
                print("end game")
                updateScore()
                playerDirection = .down
                //animation has completed
                scene.scorePosition = nil
                scene.playerPosition.removeAll()
                renderChange()
                //return to menu
                scene.currentScore.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.currentScore.isHidden = true
                }
                scene.gameBackGround.run(SKAction.scale(to: 0, duration: 0.4)) {
                    self.scene.gameBackGround.isHidden = true
                    self.scene.gameLogo.isHidden = false
                    self.scene.gameLogo.run(SKAction.move(to: CGPoint(x: 0, y: (self.scene.frame.size.height / 2) - 200), duration: 0.5)) {
                        self.scene.playButton.isHidden = false
                        self.scene.playButton.run(SKAction.scale(to: 1, duration: 0.3))
                        self.scene.bestScore.run(SKAction.move(to: CGPoint(x: 0, y: self.scene.gameLogo.position.y - 50), duration: 0.3))
                    }
                }
            }
        }
    }
    
    private func updateScore() {
        if currentScore > UserDefaults.standard.integer(forKey: "bestScore") {
            UserDefaults.standard.set(currentScore, forKey: "bestScore")
        }
        currentScore = 0
        scene.currentScore.text = "Score: 0"
        scene.bestScore.text = "Best Score: \(UserDefaults.standard.integer(forKey: "bestScore"))"
    }
}

enum PlayerDirection {
    case left
    case right
    case up
    case down
    case dead
}
