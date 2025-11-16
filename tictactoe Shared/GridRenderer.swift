//
//  GridRenderer.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import SpriteKit

/// Responsible for rendering and managing the tic-tac-toe grid lines.
///
/// This class handles the creation, styling, and lifecycle of the grid line nodes.
/// It provides methods for rendering, fading, and restoring the grid appearance.
final class GridRenderer {
    
    // MARK: - Properties
    
    /// The scene in which grid lines are rendered.
    private weak var scene: SKScene?
    
    /// The current grid line nodes.
    private var gridLines: [SKShapeNode] = []
    
    /// The scaling factor for the grid relative to the scene size.
    private let scaleFactor: CGFloat
    
    /// The number of rows/columns in the grid.
    private let dimension: Int
    
    /// The width of grid lines.
    private let lineWidth: CGFloat
    
    /// The color to use for grid lines.
    private let lineColor: SKColor
    
    // MARK: - Initialization
    
    /// Creates a new grid renderer.
    ///
    /// - Parameters:
    ///   - scene: The scene in which to render grid lines.
    ///   - scaleFactor: The scaling factor for the grid (default: 0.85).
    ///   - dimension: The number of rows/columns (default: 3).
    ///   - lineWidth: The width of grid lines (default: 2).
    ///   - lineColor: The color of grid lines (default: .separator).
    init(scene: SKScene,
         scaleFactor: CGFloat = 0.85,
         dimension: Int = 3,
         lineWidth: CGFloat = 2,
         lineColor: SKColor = .separator) {
        self.scene = scene
        self.scaleFactor = scaleFactor
        self.dimension = dimension
        self.lineWidth = lineWidth
        self.lineColor = lineColor
    }
    
    // MARK: - Public Methods
    
    /// Renders the grid in the specified frame.
    ///
    /// This method clears any existing grid lines and draws new ones
    /// based on the current frame size.
    ///
    /// - Parameter frame: The frame in which to render the grid.
    func render(in frame: CGRect) {
        clear()
        
        let layout = GridLayout(
            frame: frame,
            scaleFactor: scaleFactor,
            dimension: dimension
        )
        
        drawVerticalLines(using: layout)
        drawHorizontalLines(using: layout)
    }
    
    /// Fades the grid lines to the specified alpha value.
    ///
    /// - Parameters:
    ///   - alpha: The target alpha value (0.0 to 1.0).
    ///   - duration: The duration of the fade animation.
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
    
    /// Draws vertical grid lines.
    ///
    /// - Parameter layout: The grid layout to use for positioning.
    private func drawVerticalLines(using layout: GridLayout) {
        let positions = layout.verticalLinePositions()
        
        for x in positions {
            let startPoint = CGPoint(x: x, y: layout.gridOrigin.y)
            let endPoint = CGPoint(x: x, y: layout.gridOrigin.y + layout.gridSize)
            let line = createLine(from: startPoint, to: endPoint)
            addLine(line)
        }
    }
    
    /// Draws horizontal grid lines.
    ///
    /// - Parameter layout: The grid layout to use for positioning.
    private func drawHorizontalLines(using layout: GridLayout) {
        let positions = layout.horizontalLinePositions()
        
        for y in positions {
            let startPoint = CGPoint(x: layout.gridOrigin.x, y: y)
            let endPoint = CGPoint(x: layout.gridOrigin.x + layout.gridSize, y: y)
            let line = createLine(from: startPoint, to: endPoint)
            addLine(line)
        }
    }
    
    /// Creates a styled line node from start to end point.
    ///
    /// - Parameters:
    ///   - start: The starting point of the line.
    ///   - end: The ending point of the line.
    /// - Returns: A configured shape node representing the line.
    private func createLine(from start: CGPoint, to end: CGPoint) -> SKShapeNode {
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        let line = SKShapeNode(path: path)
        line.strokeColor = lineColor
        line.lineWidth = lineWidth
        line.lineCap = .round
        return line
    }
    
    /// Adds a line to the scene and tracks it internally.
    ///
    /// - Parameter line: The line node to add.
    private func addLine(_ line: SKShapeNode) {
        guard let scene else { return }
        scene.addChild(line)
        gridLines.append(line)
    }
}
