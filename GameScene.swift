//
//  GameScene.swift
//  FlappyTurd
//
//  Created by Melody Cao and Kevin Gu on 12/1/22.
//

// Imports framework kits
import SpriteKit
import GameplayKit

// Declares the states that the game can be in: Active (currently playing) and Game Over (player died)
enum GameState: Equatable {
    case active, gameOver

}

// Defining the physics bodies that exist within the game
struct PhysicsCategory {
    static let None: UInt32 = 0
    static let Player: UInt32 = 0b1
    static let Obstacle: UInt32 = 0b10
    static let PlayerBody: UInt32 = 0b100
}

class GameScene: SKScene, SKPhysicsContactDelegate {
    
    // Variables for movement
    let fixedDelta: CFTimeInterval = 1.0 / 60.0 /* 60 FPS */
    let scrollSpeed: CGFloat = 200
    let pipeGapSpace = 625.0
    var scrollNode: SKNode!
    var cloudNode: SKNode!
    var player: SKSpriteNode!
    var obstacleSpawner: SKNode!
    var skyColor:SKColor!

    var sinceTouch: CFTimeInterval = 0
    var upTube: SKSpriteNode!
    var downTube: SKSpriteNode!
    var pipeTextureUp: SKTexture!
    var pipeTextureDown: SKTexture!
    var movePipesAndRemove: SKAction!
    var pipes: SKNode!
    var moving:SKNode!
    
    // User-interface Connections
    var playButton: CustomButtonNode!
    var buttonRestart: RestartButton!
    
    // Game management
    var gameState: GameState = .active

    
    override func didMove(to view: SKView) {
        // Sets up the scene
        skyColor = SKColor(red: 164.0/255.0, green: 209.0/255.0, blue: 251.0/255.0, alpha: 1.0)
        self.backgroundColor = skyColor

        // Recursive node search for 'player' (child of referenced node)
        player = (self.childNode(withName: "//player") as! SKSpriteNode)

        // RESTART BUTTON:
        // Sets UI connections
        buttonRestart = (self.childNode(withName: "buttonRestart") as! RestartButton)

        // Setup restart button selection handler
        buttonRestart.selectedHandler = {

            // Grab reference to our SpriteKit view
            let skView = self.view as SKView?

            // Loads game scene
            let scene = GameScene(fileNamed:"GameScene") as GameScene?

            // Ensures correct aspect mode
            scene?.scaleMode = .aspectFill

            // Restarts game scene
            skView?.presentScene(scene)
        }

        // Hides restart button once game starts
        buttonRestart.state = .RestartButtonStateHidden

        // Moves the pipes
        moving = SKNode()
        self.addChild(moving)
        pipes = SKNode()
        moving.addChild(pipes)

        // Creates the pipes textures
        pipeTextureUp = SKTexture(imageNamed: "upTube")
        pipeTextureUp.filteringMode = .nearest
        pipeTextureDown = SKTexture(imageNamed: "downTube")
        pipeTextureDown.filteringMode = .nearest

        // Creates pipe movement actions
        let distanceToMove = CGFloat(self.frame.size.width + 2.9 * pipeTextureUp.size().width)
        let movePipes = SKAction.moveBy(x: -distanceToMove, y:0.0, duration:TimeInterval(0.0045 * distanceToMove))
        let removePipes = SKAction.removeFromParent()
        movePipesAndRemove = SKAction.sequence([movePipes, removePipes])

        // Spawns the pipes
        let spawn = SKAction.run(spawnPipes)
        let delay = SKAction.wait(forDuration: TimeInterval(2.5))
        let spawnThenDelay = SKAction.sequence([spawn, delay])
        let spawnThenDelayForever = SKAction.repeatForever(spawnThenDelay)
        self.run(spawnThenDelayForever)
        
        // Set physics contact delegate
        physicsWorld.contactDelegate = self
    }
    
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        // Game is over when player touches anything

        print("TOUCHED SOMETHING!")

        // Ensures only called when game is running
        if gameState != .active { return }

        // Flash background if contact is detected
        self.removeAction(forKey: "flash")
        self.run(SKAction.sequence([SKAction.repeat(SKAction.sequence([SKAction.run({
            self.backgroundColor = SKColor(red: 1, green: 0, blue: 0, alpha: 1.0)
            }),SKAction.wait(forDuration: TimeInterval(0.05)), SKAction.run({
                self.backgroundColor = self.skyColor
            }), SKAction.wait(forDuration: TimeInterval(0.05))]), count:4), SKAction.run({})]), withKey: "flash")

        // Changes game state to game over
        gameState = .gameOver

        // Stop any new angular velocity being applied
        player.physicsBody?.allowsRotation = false

        // Resets angular velocity
        player.physicsBody?.angularVelocity = 0

        // Shows restart button
        buttonRestart.state = .RestartButtonStateActive
    }
    
    
    // Function to spawn the pipes indefinitely
    func spawnPipes() {
        
        // Only spawns pipes if game is ACTIVE, not Game Over
        if playButton.state == .Hidden {
            if gameState != .active { return }

            // Defines a pair of pipes and its position
            let pipePair = SKNode()
            pipePair.position = CGPoint( x: self.frame.size.width + pipeTextureUp.size().width * 2.5, y: 0 )
            pipePair.zPosition = -10
            
            // Defines random heights to spawn at
            let height = UInt32( self.frame.size.height / 4)
            let y = Double(arc4random_uniform(height))
            
            // Defines downward facing tube's position and texture traits
            let downTube = SKSpriteNode(texture: pipeTextureDown)
            downTube.setScale(0.5)
            downTube.position = CGPoint(x: 0.0, y: y + Double(downTube.size.height) + pipeGapSpace)
            
            downTube.physicsBody = SKPhysicsBody(rectangleOf: downTube.size)
            downTube.physicsBody?.isDynamic = false
            downTube.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
            downTube.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            pipePair.addChild(downTube)
            
            // Defines upward facing tube's position and texture traits
            let upTube = SKSpriteNode(texture: pipeTextureUp)
            upTube.setScale(0.5)
            upTube.position = CGPoint(x: 0.0, y: y)
            
            upTube.physicsBody = SKPhysicsBody(rectangleOf: upTube.size)
            upTube.physicsBody?.isDynamic = false
            upTube.physicsBody?.categoryBitMask = PhysicsCategory.Obstacle
            upTube.physicsBody?.contactTestBitMask = PhysicsCategory.Player
            pipePair.addChild(upTube)
            
            // Runs the movement
            pipePair.run(movePipesAndRemove)
            pipes.addChild(pipePair)
        }
    }
    
    
    // Function for user touch input
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    // Called when a touch begins
    if gameState != .active { return }
    if playButton.state == .Hidden {

        // Applies vertical impulse
        player.physicsBody?.applyImpulse(CGVector(dx: 0, dy: 300))

        // Apply subtle rotation
        player.physicsBody?.applyImpulse(CGVectorMake(0,600))

        // Resets touch timer
        sinceTouch = 0
        }
    }

    // Function for loading scene, checking for errors
    override func sceneDidLoad() {
        super.sceneDidLoad()
        
        // Set reference to scroll Node
        if let scrollNode = self.childNode(withName: "scrollNode") {
            self.scrollNode = scrollNode
        } else {
            print("ScrollNode could not be connected properly")
        }
        
        // Set reference to cloud Node
        if let cloudNode = self.childNode(withName: "cloudNode") {
            self.cloudNode = cloudNode
        } else {
            print("cloudNode could not be connected properly")
        }
        
        // Set reference to play button node
        if let playButton = self.childNode(withName: "playButton") as? CustomButtonNode {
          self.playButton = playButton
        } else {
          print("playButton was not initialized properly")
        }
        
        // Sets button state as Active originally
        playButton.selectedHandler = {
          self.gameState = .active
        }
        
        // Defining player sprite
        let sprite = SKSpriteNode(imageNamed: "poo.png")
        sprite.physicsBody = SKPhysicsBody(circleOfRadius: sprite.size.width / 5)
    }
    
    // Function for updating scoll
    override func update(_ currentTime: TimeInterval) {
        super.update(currentTime)
        // Called before each frame is rendered
        
        // Skip game update if game no longer active
        if gameState != .active { return }
        
        // Player stays in the air when your in the start menu
        if playButton.state == .Hidden {
            player.physicsBody?.affectedByGravity = true
            
            // Process world scrolling
            cloudScroll()
            scrollWorld()
        }
    }
    
    // Function to scroll clouds
    func cloudScroll() {
        
        // Scrolls clouds at lower speed than ground to have sense of distance
        cloudNode.position.x -= scrollSpeed * 0.3 * CGFloat(fixedDelta)

        // Loop through scroll layer nodes
        for cloud in cloudNode.children as! [SKSpriteNode] {
            
            // Get cloud node position, convert node position to scene space
            let cloudPosition = cloudNode.convert(cloud.position, to: self)

            // Check if cloud sprite has left the scene
            if cloudPosition.x <= -cloud.size.width / 2 {

                // Reposition cloud sprite to the second starting position
                let newPosition = CGPoint(x: (self.size.width) + cloud.size.width, y: cloudPosition.y)

                // Convert new node position back to scroll layer space
                cloud.position = self.convert(newPosition, to: cloudNode)
            }
        }
    }
        
    // Function to scroll ground/world
    func scrollWorld() {
        // Scroll World
        scrollNode.position.x -= scrollSpeed * CGFloat(fixedDelta)
        
        // Loop through scroll layer nodes
        for ground in scrollNode.children as! [SKSpriteNode] {

            // Get ground node position, convert node position to scene space
            let groundPosition = scrollNode.convert(ground.position, to: self)

            // Check if ground sprite has left the scene
            if groundPosition.x <= -ground.size.width / 2 {

                // Reposition ground sprite to the second starting position
                let newPosition = CGPoint(x: (self.size.width / 2) + ground.size.width, y: groundPosition.y)

                // Convert new node position back to scroll layer space
                ground.position = self.convert(newPosition, to: scrollNode)
            }
        }
    }
}
