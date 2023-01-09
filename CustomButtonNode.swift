//
//  CustomButtonNode.swift
//  FlappyTurd
//
//  Created by Melody Cao and Kevin Gu on 12/1/22.
//

import SpriteKit

// Defines button states
enum ButtonNodeState {
    case Active, Selected, Hidden
}

class CustomButtonNode: SKSpriteNode {
    // Default state of button is enabled
    var isButtonEnabled: Bool = true
    
    // Setup a dummy action closure
    var selectedHandler: () -> Void = { print("No button action set") }

    // Button state management
    var state: ButtonNodeState = .Active {
        didSet {
            switch state {
                
            case .Active:
                // Enable touch
                self.isUserInteractionEnabled = true

                // Visible
                self.alpha = 1
                break
                
                
            case .Selected:
                // Semi transparent
                self.alpha = 0.7
                break
                
                
            case .Hidden:
                // Disable touch
                self.isUserInteractionEnabled = false

                // Hide
                self.alpha = 0
                break
            }
        }
    }

    // Support for NSKeyedArchiver (loading objects from SK Scene Editor)
    required init?(coder aDecoder: NSCoder) {

        // Call parent initializer e.g. SKSpriteNode
        super.init(coder: aDecoder)

        // Enable touch on button node
        self.isUserInteractionEnabled = true
    }

    // Touch handling
    // Beginning of touch
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if isButtonEnabled {
            // Change state
            state = .Selected
        }
    }
    // Once button has finished being pressed
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isButtonEnabled {
        
            // Run code assigned by other section
            selectedHandler()
            // Change state back to active
            state = .Hidden
        }
    }
}
