//
//  GridRenderer.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Handles rendering of the tic-tac-toe grid lines.
///
/// This class is responsible for drawing, animating, and managing
/// the visual representation of the game grid.
final class GridRenderer {
    
    // MARK: - Properties
    
    private weak var scene: SKScene?
    private var gridLines: [SKShapeNode] = []
    
    private let gridScaleFactor: CGFloat
    private let gridDimension: Int
    private let lineWidth: CGFloat
    
    // MARK: - Initialization
    
    /// Creates a new grid renderer.
    ///
    /// - Parameters:
    ///   - scene: The scene that will contain the grid.
    ///   - scaleFactor: The scaling factor for the grid relative to the scene size.
    ///   - dimension: The number of rows/columns in the grid (typically 3).
    ///   - lineWidth: The width of the grid lines.
    init(scene: SKScene,
         scaleFactor: CGFloat = 0.85,
         dimension: Int = 3,
         lineWidth: CGFloat = 2) {
        self.scene = scene
        self.gridScaleFactor = scaleFactor
        self.gridDimension = dimension
        self.lineWidth = lineWidth
    }
    
    // MARK: - Public Methods
    
    /// Renders the grid in the specified frame.
    ///
    /// Clears any existing grid and draws a new one based on the current frame size.
    ///
    /// - Parameter frame: The frame in which to render the grid.
    func render(in frame: CGRect) {
        clear()
        let layout = GridLayout(
            frame: frame,
            scaleFactor: gridScaleFactor,
            dimension: gridDimension
        )
        drawVerticalLines(layout: layout)
        drawHorizontalLines(layout: layout)
    }
    
    /// Fades the grid lines to the specified alpha value.
    ///
    /// - Parameters:
    ///   - alpha: The target alpha value (0.0 to 1.0).
    ///   - duration: The animation duration.
    func fade(to alpha: CGFloat, duration: TimeInterval) {
        let fadeAction = SKAction.fadeAlpha(to: alpha, duration: duration)
        fadeAction.timingMode = .easeInEaseOut
        gridLines.forEach { $0.run(fadeAction) }
    }
    
    /// Restores the grid lines to full opacity.
    func restore() {
        gridLines.forEach { $0.alpha = 1.0 }
    }
    
    // MARK: - Private Methods
    
    /// Removes all grid lines from the scene.
    private func clear() {
        gridLines.forEach { $0.removeFromParent() }
        gridLines.removeAll()
    }
    
    /// Draws the vertical grid lines.
    private func drawVerticalLines(layout: GridLayout) {
        for i in 1..<gridDimension {
            let x = layout.gridOrigin.x + CGFloat(i) * layout.cellSize.width
            let line = createLine(
                from: CGPoint(x: x, y: layout.gridOrigin.y),
                to: CGPoint(x: x, y: layout.gridOrigin.y + layout.gridSize)
            )
            scene?.addChild(line)
            gridLines.append(line)
        }
    }
    
    /// Draws the horizontal grid lines.
    private func drawHorizontalLines(layout: GridLayout) {
        for i in 1..<gridDimension {
            let y = layout.gridOrigin.y + CGFloat(i) * layout.cellSize.height
            let line = createLine(
                from: CGPoint(x: layout.gridOrigin.x, y: y),
                to: CGPoint(x: layout.gridOrigin.x + layout.gridSize, y: y)
            )
            scene?.addChild(line)
            gridLines.append(line)
        }
    }
    
    /// Creates a styled line from one point to another.
    private func createLine(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = .separator
        line.lineWidth = lineWidth
        line.lineCap = .round
        return line
    }
}
