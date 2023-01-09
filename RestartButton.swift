//
//  RestartButton.swift
//  FlappyTurd
//
//  Created by Melody Cao and Kevin Gu on 12/4/22.
//

import Foundation
import SpriteKit

// Defines button states
enum RestartButtonState {
    case RestartButtonStateActive, RestartButtonStateSelected, RestartButtonStateHidden
}

class RestartButton: SKSpriteNode {
    
    // Setup a dummy action closure
    var selectedHandler: () -> Void = { print("No button action set") }
    
    // Button state management
    var state: RestartButtonState = .RestartButtonStateActive {
        didSet {
            switch state {
            case .RestartButtonStateActive:
                // Enable touch
                self.isUserInteractionEnabled = true
                
                // Visible
                self.alpha = 1
                break
            case .RestartButtonStateSelected:
                // Semi transparent
                self.alpha = 0.7
                break
            case .RestartButtonStateHidden:
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
    
    // Touch handling (same commenting as CustomButtonNode)
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        state = .RestartButtonStateSelected
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        selectedHandler()
        state = .RestartButtonStateActive
    }
}
