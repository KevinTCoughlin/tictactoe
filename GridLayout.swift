//
//  GridLayout.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import CoreGraphics

/// Handles layout calculations for the tic-tac-toe grid.
///
/// This struct encapsulates all coordinate mathematics for positioning
/// the grid, cells, and converting between scene coordinates and cell indices.
struct GridLayout {
    
    // MARK: - Properties
    
    let frame: CGRect
    let scaleFactor: CGFloat
    let dimension: Int
    
    // MARK: - Computed Properties
    
    /// The size of each cell in the grid.
    var cellSize: CGSize {
        let minSide = min(frame.width, frame.height)
        let gridSize = minSide * scaleFactor
        let cellDimension = gridSize / CGFloat(dimension)
        return CGSize(width: cellDimension, height: cellDimension)
    }
    
    /// The origin point (bottom-left corner) of the grid.
    var gridOrigin: CGPoint {
        let totalGridSize = cellSize.width * CGFloat(dimension)
        return CGPoint(
            x: frame.midX - totalGridSize / 2,
            y: frame.midY - totalGridSize / 2
        )
    }
    
    /// The total size of the grid (width and height are equal).
    var gridSize: CGFloat {
        cellSize.width * CGFloat(dimension)
    }
    
    // MARK: - Coordinate Conversion
    
    /// Returns the scene position for the center of a given cell index.
    ///
    /// - Parameter cellIndex: The cell index (0-8 for a 3×3 grid).
    /// - Returns: The center point of the cell in scene coordinates.
    func position(for cellIndex: Int) -> CGPoint {
        let row = cellIndex / dimension
        let column = cellIndex % dimension
        
        // Invert row for SpriteKit's bottom-up coordinate system
        // Row 0 should be at the top, row 2 at the bottom
        let invertedRow = (dimension - 1) - row
        
        return CGPoint(
            x: gridOrigin.x + CGFloat(column) * cellSize.width + cellSize.width / 2,
            y: gridOrigin.y + CGFloat(invertedRow) * cellSize.height + cellSize.height / 2
        )
    }
    
    /// Returns the cell index for a given point in scene coordinates.
    ///
    /// - Parameter point: A point in scene coordinates.
    /// - Returns: The cell index (0-8) if the point is within the grid, or `nil` otherwise.
    func cellIndex(at point: CGPoint) -> Int? {
        guard isPointInGrid(point) else { return nil }
        
        let column = Int((point.x - gridOrigin.x) / cellSize.width)
        let invertedRow = Int((point.y - gridOrigin.y) / cellSize.height)
        
        // Invert row back to logical coordinates
        // (SpriteKit Y increases upward, but our row 0 is conceptually at the top)
        let row = (dimension - 1) - invertedRow
        let index = row * dimension + column
        
        let maxIndex = dimension * dimension
        guard (0..<maxIndex).contains(index) else { return nil }
        return index
    }
    
    // MARK: - Private Helpers
    
    /// Returns `true` if the point is within the grid bounds.
    private func isPointInGrid(_ point: CGPoint) -> Bool {
        let gridMaxX = gridOrigin.x + gridSize
        let gridMaxY = gridOrigin.y + gridSize
        
        return point.x >= gridOrigin.x && point.x <= gridMaxX &&
               point.y >= gridOrigin.y && point.y <= gridMaxY
    }
}
