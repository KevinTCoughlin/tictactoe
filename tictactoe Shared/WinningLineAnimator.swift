//
//  WinningLineAnimator.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Responsible for creating and animating the winning line effect.
///
/// This class creates a multi-layered winning line with glow effects and animations.
/// The line consists of three layers:
/// - Outer glow: Subtle, wide glow for depth
/// - Inner glow: Brighter, medium glow for emphasis
/// - Core line: Solid, vibrant line at the center
///
/// The animation includes a drawing effect and a subtle pulsing loop.
final class WinningLineAnimator {
    
    // MARK: - Constants
    
    /// Node name identifier for winning line containers.
    private static let nodeName = "winLine"
    
    // MARK: - Properties
    
    /// The scene in which to render the winning line.
    private weak var scene: SKScene?
    
    /// The width of the core line.
    private let lineWidth: CGFloat
    
    /// The width of the glow effect.
    private let glowWidth: CGFloat
    
    /// The duration of the drawing animation.
    private let drawDuration: TimeInterval
    
    /// The duration of each pulse cycle.
    private let pulseDuration: TimeInterval
    
    // MARK: - Initialization
    
    /// Creates a new winning line animator.
    ///
    /// - Parameters:
    ///   - scene: The scene in which to render the winning line.
    ///   - lineWidth: The width of the core line (default: 8).
    ///   - glowWidth: The width of the glow effect (default: 16).
    ///   - drawDuration: The duration of the drawing animation (default: 0.5).
    ///   - pulseDuration: The duration of each pulse cycle (default: 0.8).
    init(scene: SKScene,
         lineWidth: CGFloat = 8,
         glowWidth: CGFloat = 16,
         drawDuration: TimeInterval = 0.5,
         pulseDuration: TimeInterval = 0.8) {
        self.scene = scene
        self.lineWidth = lineWidth
        self.glowWidth = glowWidth
        self.drawDuration = drawDuration
        self.pulseDuration = pulseDuration
    }
    
    // MARK: - Public Methods
    
    /// Shows the winning line with animation.
    ///
    /// - Parameters:
    ///   - startPosition: The starting point of the line.
    ///   - endPosition: The ending point of the line.
    func showWinningLine(from startPosition: CGPoint, to endPosition: CGPoint) {
        guard let scene else { return }
        
        let container = createWinningLineContainer(from: startPosition, to: endPosition)
        scene.addChild(container)
    }
    
    /// Removes the winning line from the scene.
    func removeWinningLine() {
        guard let scene else { return }
        
        scene.children
            .filter { $0.name == Self.nodeName }
            .forEach { $0.removeFromParent() }
    }
    
    // MARK: - Private Methods - Container Creation
    
    /// Creates the complete winning line container with all layers.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    /// - Returns: A node containing all layers of the winning line.
    private func createWinningLineContainer(from start: CGPoint, to end: CGPoint) -> SKNode {
        let container = SKNode()
        container.name = Self.nodeName
        
        // Create the three layers
        let outerGlow = createOuterGlowLayer(from: start, to: end)
        let innerGlow = createInnerGlowLayer(from: start, to: end)
        let coreLine = createCoreLineLayer(from: start, to: end)
        
        // Add layers to container
        container.addChild(outerGlow)
        container.addChild(innerGlow)
        container.addChild(coreLine)
        
        // Animate the layers
        let layers = [outerGlow, innerGlow, coreLine]
        animateWinningLine(layers: layers)
        addPulsingAnimation(to: container)
        
        return container
    }
    
    // MARK: - Private Methods - Layer Creation
    
    /// Creates the outer glow layer.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    /// - Returns: A shape node representing the outer glow.
    private func createOuterGlowLayer(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        createGlowLayer(
            from: start,
            to: end,
            color: .systemBlue.withAlphaComponent(0.2),
            width: glowWidth * 1.5,
            glowAmount: 20
        )
    }
    
    /// Creates the inner glow layer.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    /// - Returns: A shape node representing the inner glow.
    private func createInnerGlowLayer(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        createGlowLayer(
            from: start,
            to: end,
            color: .systemBlue.withAlphaComponent(0.5),
            width: glowWidth,
            glowAmount: 12
        )
    }
    
    /// Creates the core line layer.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    /// - Returns: A shape node representing the core line.
    private func createCoreLineLayer(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
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
    
    /// Creates a generic glow layer with the specified properties.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    ///   - color: The stroke color.
    ///   - width: The line width.
    ///   - glowAmount: The glow width.
    /// - Returns: A configured shape node.
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
    
    // MARK: - Private Methods - Animation
    
    /// Animates all layers of the winning line with a drawing effect.
    ///
    /// Each layer fades in with a slight delay to create a depth effect.
    ///
    /// - Parameter layers: The layers to animate (outer glow, inner glow, core line).
    private func animateWinningLine(layers: [SKShapeNode]) {
        let delays: [TimeInterval] = [0.0, 0.05, 0.1]
        
        for (index, layer) in layers.enumerated() {
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
    
    /// Animates a stroke drawing effect for a shape node.
    ///
    /// Since SpriteKit doesn't have native strokeEnd support, this simulates
    /// the effect using alpha ramping with easing.
    ///
    /// - Parameters:
    ///   - shapeNode: The shape node to animate.
    ///   - duration: The duration of the animation.
    ///   - delay: The delay before starting the animation.
    private func animateStrokeDraw(_ shapeNode: SKShapeNode, duration: TimeInterval, delay: TimeInterval) {
        let drawAction = SKAction.customAction(withDuration: duration) { node, elapsedTime in
            let progress = elapsedTime / duration
            // Use cubic ease-out for smoother drawing effect
            let easedProgress = 1 - pow(1 - progress, 3)
            
            if let shape = node as? SKShapeNode {
                // Simulate progressive revelation with alpha
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
    ///
    /// The pulse starts after the drawing animation completes and loops forever.
    ///
    /// - Parameter container: The container node to pulse.
    private func addPulsingAnimation(to container: SKNode) {
        // Wait for the draw animation to complete
        let waitAction = SKAction.wait(forDuration: drawDuration + 0.1)
        
        // Create a gentle pulse effect
        let scaleUp = SKAction.scale(to: 1.05, duration: pulseDuration)
        scaleUp.timingMode = .easeInEaseOut
        
        let scaleDown = SKAction.scale(to: 1.0, duration: pulseDuration)
        scaleDown.timingMode = .easeInEaseOut
        
        let pulse = SKAction.sequence([scaleUp, scaleDown])
        let repeatPulse = SKAction.repeatForever(pulse)
        
        container.run(SKAction.sequence([waitAction, repeatPulse]))
    }
}
