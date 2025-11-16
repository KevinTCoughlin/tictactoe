//
//  MarkRenderer.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Handles rendering of player marks (X and O) on the game board.
///
/// This class manages the creation, animation, and layout of player marks,
/// keeping track of which marks are placed in which cells.
final class MarkRenderer {
    
    // MARK: - Properties
    
    private weak var scene: SKScene?
    private var marks: [Int: SKLabelNode] = [:]
    
    private let fontScale: CGFloat
    private let animationDuration: TimeInterval
    
    // MARK: - Initialization
    
    /// Creates a new mark renderer.
    ///
    /// - Parameters:
    ///   - scene: The scene that will contain the marks.
    ///   - fontScale: The font size scale relative to cell size.
    ///   - animationDuration: The duration of the mark appearance animation.
    init(scene: SKScene,
         fontScale: CGFloat = 0.65,
         animationDuration: TimeInterval = 0.15) {
        self.scene = scene
        self.fontScale = fontScale
        self.animationDuration = animationDuration
    }
    
    // MARK: - Public Methods
    
    /// Places a mark at the specified cell with animation.
    ///
    /// - Parameters:
    ///   - symbol: The symbol to display (typically "X" or "O").
    ///   - cellIndex: The cell index where the mark should be placed.
    ///   - position: The scene position for the mark.
    ///   - cellSize: The size of the cell (used to calculate font size).
    func placeMark(_ symbol: String, at cellIndex: Int, position: CGPoint, cellSize: CGSize) {
        let label = createLabel(
            symbol: symbol,
            position: position,
            fontSize: cellSize.width * fontScale
        )
        marks[cellIndex] = label
        scene?.addChild(label)
        animateMark(label)
    }
    
    /// Re-positions all existing marks after a layout change.
    ///
    /// - Parameter layout: The new grid layout to use for positioning.
    func relayout(using layout: GridLayout) {
        marks.forEach { cellIndex, markNode in
            markNode.position = layout.position(for: cellIndex)
        }
    }
    
    /// Removes all marks from the scene.
    func clear() {
        marks.values.forEach { $0.removeFromParent() }
        marks.removeAll()
    }
    
    // MARK: - Private Methods
    
    /// Creates a label node for displaying a mark.
    private func createLabel(symbol: String, position: CGPoint, fontSize: CGFloat) -> SKLabelNode {
        let label = SKLabelNode(fontNamed: ".AppleSystemUIFontRounded-Bold")
        label.fontSize = fontSize
        label.fontColor = .label
        label.horizontalAlignmentMode = .center
        label.verticalAlignmentMode = .center
        label.text = symbol
        label.position = position
        label.setScale(0.1)
        label.alpha = 0
        return label
    }
    
    /// Animates a mark with a smooth spring-like scale and fade effect.
    private func animateMark(_ markNode: SKLabelNode) {
        let fadeIn = SKAction.fadeIn(withDuration: animationDuration)
        let scaleUp = SKAction.scale(to: 1.15, duration: animationDuration)
        scaleUp.timingMode = .easeOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: animationDuration)
        scaleDown.timingMode = .easeInEaseOut
        
        let appearGroup = SKAction.group([fadeIn, scaleUp])
        let sequence = SKAction.sequence([appearGroup, scaleDown])
        
        markNode.run(sequence)
    }
}
