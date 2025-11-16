//
//  WinningLineAnimator.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Handles the visual effects for the winning line animation.
///
/// This class creates a layered, animated line that highlights the winning
/// combination of three cells. The animation includes multiple glow layers
/// and a pulsing effect for emphasis.
final class WinningLineAnimator {
    
    // MARK: - Properties
    
    private static let nodeName = "winLine"
    
    private weak var scene: SKScene?
    private let lineWidth: CGFloat
    private let glowWidth: CGFloat
    
    // MARK: - Initialization
    
    /// Creates a new winning line animator.
    ///
    /// - Parameters:
    ///   - scene: The scene that will contain the winning line.
    ///   - lineWidth: The width of the core line.
    ///   - glowWidth: The width of the glow effect.
    init(scene: SKScene, lineWidth: CGFloat = 8, glowWidth: CGFloat = 16) {
        self.scene = scene
        self.lineWidth = lineWidth
        self.glowWidth = glowWidth
    }
    
    // MARK: - Public Methods
    
    /// Shows an animated winning line from start to end position.
    ///
    /// The line consists of multiple layers with glow effects and animates
    /// with a drawing effect followed by a subtle pulse.
    ///
    /// - Parameters:
    ///   - startPosition: The starting point of the line in scene coordinates.
    ///   - endPosition: The ending point of the line in scene coordinates.
    func showWinningLine(from startPosition: CGPoint, to endPosition: CGPoint) {
        let container = createWinningLineContainer(from: startPosition, to: endPosition)
        scene?.addChild(container)
    }
    
    /// Removes the winning line from the scene, if present.
    func removeWinningLine() {
        scene?.children
            .filter { $0.name == Self.nodeName }
            .forEach { $0.removeFromParent() }
    }
    
    // MARK: - Private Methods
    
    /// Creates the complete winning line container with all layers.
    private func createWinningLineContainer(from start: CGPoint, to end: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = Self.nodeName
        
        // Layer 1: Outer glow (subtle, wider)
        let outerGlow = createGlowLayer(
            from: start,
            to: end,
            color: .systemBlue.withAlphaComponent(0.2),
            width: glowWidth * 1.5,
            glowAmount: 20
        )
        container.addChild(outerGlow)
        
        // Layer 2: Inner glow (brighter, medium)
        let innerGlow = createGlowLayer(
            from: start,
            to: end,
            color: .systemBlue.withAlphaComponent(0.5),
            width: glowWidth,
            glowAmount: 12
        )
        container.addChild(innerGlow)
        
        // Layer 3: Core line (solid, vibrant)
        let coreLine = createCoreLine(from: start, to: end)
        container.addChild(coreLine)
        
        animateWinningLine(layers: [outerGlow, innerGlow, coreLine])
        addPulsingAnimation(to: container)
        
        return container
    }
    
    /// Creates a glow layer for the winning line.
    private func createGlowLayer(from start: CGPoint,
                                 to end: CGPoint,
                                 color: SKColor,
                                 width: CGFloat,
                                 glowAmount: CGFloat) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let glow = SKShapeNode(path: path)
        glow.strokeColor = color
        glow.lineWidth = width
        glow.lineCap = .round
        glow.glowWidth = glowAmount
        glow.alpha = 0
        return glow
    }
    
    /// Creates the core line for the winning line.
    private func createCoreLine(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = .white
        line.lineWidth = lineWidth
        line.lineCap = .round
        line.glowWidth = 6
        line.alpha = 0
        return line
    }
    
    /// Animates the winning line with a drawing effect and fade-in.
    private func animateWinningLine(layers: [SKShapeNode]) {
        let drawDuration: TimeInterval = 0.5
        let delays: [TimeInterval] = [0.0, 0.05, 0.1]
        
        for (index, layer) in layers.enumerated() {
            guard index < delays.count else { continue }
            let delay = delays[index]
            animateStrokeDraw(layer, duration: drawDuration, delay: delay)
            
            let fadeIn = SKAction.fadeIn(withDuration: drawDuration * 0.3)
            fadeIn.timingMode = .easeIn
            
            if delay > 0 {
                layer.run(SKAction.sequence([
                    SKAction.wait(forDuration: delay),
                    fadeIn
                ]))
            } else {
                layer.run(fadeIn)
            }
        }
    }
    
    /// Animates the stroke drawing effect for a shape node.
    private func animateStrokeDraw(_ shapeNode: SKShapeNode,
                                   duration: TimeInterval,
                                   delay: TimeInterval) {
        let drawAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / duration
            // Use ease-out timing for smoother drawing
            let easedProgress = 1 - pow(1 - progress, 3)
            
            if let shape = node as? SKShapeNode {
                // Simulate stroke drawing by revealing the line progressively
                // Note: SpriteKit doesn't have direct strokeEnd, so we use alpha ramp
                shape.alpha = min(1.0, easedProgress * 1.5)
            }
        }
        
        drawAction.timingMode = .easeOut
        
        if delay > 0 {
            shapeNode.run(SKAction.sequence([
                SKAction.wait(forDuration: delay),
                drawAction
            ]))
        } else {
            shapeNode.run(drawAction)
        }
    }
    
    /// Adds a subtle pulsing animation to emphasize the winning line.
    private func addPulsingAnimation(to container: SKNode) {
        // Wait for the draw animation to complete
        let waitAction = SKAction.wait(forDuration: 0.6)
        
        // Create a gentle pulse effect
        let scaleUp = SKAction.scale(to: 1.05, duration: 0.8)
        scaleUp.timingMode = .easeInEaseOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: 0.8)
        scaleDown.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        container.run(SKAction.sequence([waitAction, repeatPulse]))
    }
}
