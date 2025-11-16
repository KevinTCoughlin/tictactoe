//
//  MarkRenderer.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Responsible for rendering and animating player marks (X and O) on the game board.
///
/// This class manages the creation, positioning, and animation of mark labels.
/// It maintains a dictionary of marks for efficient updates and cleanup.
final class MarkRenderer {
    
    // MARK: - Properties
    
    /// The scene in which marks are rendered.
    private weak var scene: SKScene?
    
    /// Dictionary mapping cell indices to their corresponding mark labels.
    private var marks: [Int: SKLabelNode] = [:]
    
    /// The font scale for marks relative to cell size.
    private let fontScale: CGFloat
    
    /// The duration of mark appearance animations.
    private let animationDuration: TimeInterval
    
    /// The font name to use for marks.
    private let fontName: String
    
    /// The color to use for marks.
    private let fontColor: SKColor
    
    // MARK: - Initialization
    
    /// Creates a new mark renderer.
    ///
    /// - Parameters:
    ///   - scene: The scene in which to render marks.
    ///   - fontScale: The font scale relative to cell size (default: 0.65).
    ///   - animationDuration: The duration of mark animations (default: 0.15).
    ///   - fontName: The font name to use (default: system rounded bold).
    ///   - fontColor: The color for marks (default: .label).
    init(scene: SKScene,
         fontScale: CGFloat = 0.65,
         animationDuration: TimeInterval = 0.15,
         fontName: String = ".AppleSystemUIFontRounded-Bold",
         fontColor: SKColor = .label) {
        self.scene = scene
        self.fontScale = fontScale
        self.animationDuration = animationDuration
        self.fontName = fontName
        self.fontColor = fontColor
    }
    
    // MARK: - Public Methods
    
    /// Places a mark at the specified cell with animation.
    ///
    /// - Parameters:
    ///   - symbol: The symbol to display (e.g., "X" or "O").
    ///   - cellIndex: The cell index where the mark should be placed.
    ///   - position: The position in scene coordinates.
    ///   - cellSize: The size of the cell (used for font sizing).
    func placeMark(_ symbol: String, at cellIndex: Int, position: CGPoint, cellSize: CGSize) {
        let label = createLabel(
            symbol: symbol,
            position: position,
            fontSize: cellSize.width * fontScale
        )
        
        marks[cellIndex] = label
        
        guard let scene else { return }
        scene.addChild(label)
        
        animateMark(label)
    }
    
    /// Re-positions all existing marks based on a new layout.
    ///
    /// This is useful when the scene size changes and marks need to be repositioned.
    ///
    /// - Parameter layout: The grid layout to use for positioning.
    func relayout(using layout: GridLayout) {
        marks.forEach { cellIndex, markNode in
            markNode.position = layout.position(for: cellIndex)
            
            // Also update font size based on new cell size
            markNode.fontSize = layout.cellSize.width * fontScale
        }
    }
    
    /// Removes all marks from the scene.
    func clear() {
        marks.values.forEach { $0.removeFromParent() }
        marks.removeAll()
    }
    
    /// Returns the mark at the specified cell index, if any.
    ///
    /// - Parameter cellIndex: The cell index to query.
    /// - Returns: The mark label node if present, otherwise `nil`.
    func mark(at cellIndex: Int) -> SKLabelNode? {
        marks[cellIndex]
    }
    
    /// Returns `true` if a mark exists at the specified cell index.
    ///
    /// - Parameter cellIndex: The cell index to check.
    /// - Returns: `true` if a mark is present, `false` otherwise.
    func hasMark(at cellIndex: Int) -> Bool {
        marks[cellIndex] != nil
    }
    
    // MARK: - Private Methods
    
    /// Creates a label node for displaying a player mark.
    ///
    /// - Parameters:
    ///   - symbol: The symbol to display.
    ///   - position: The position for the label.
    ///   - fontSize: The font size to use.
    /// - Returns: A configured label node ready for animation.
    private func createLabel(symbol: String, position: CGPoint, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: fontName)
        label.fontSize = fontSize
        label.fontColor = fontColor
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = symbol
        label.position = position
        
        // Start small and transparent for animation
        label.setScale(0.1)
        label.alpha = 0
        
        return label
    }
    
    /// Animates a mark with a smooth spring-like scale and fade effect.
    ///
    /// The animation consists of:
    /// 1. Fade in while scaling up to 1.15x
    /// 2. Scale down to 1.0x for a subtle bounce effect
    ///
    /// - Parameter markNode: The mark node to animate.
    private func animateMark(_ markNode: SKLabelNode) {
        // Phase 1: Fade in and scale up
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
        let scaleUp = SKAction.scale(to: 1.15, duration: animationDuration)
        scaleUp.timingMode = .easeOut
        
        // Phase 2: Scale down to final size
        let scaleDown = SKAction.scale(to: 1.0, duration: animationDuration)
        scaleDown.timingMode = .easeInEaseOut
        
        // Combine and execute
        let appearGroup = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([appearGroup, scaleDown])
        
        markNode.run(sequence)
    }
}
