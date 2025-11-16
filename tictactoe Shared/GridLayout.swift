//
//  GridLayout.swift
//  tictactoe Shared
//
//  Created by Kevin T. Coughlin on 11/16/25.
//

import CoreGraphics

/// Handles all geometric calculations for the tic-tac-toe grid layout.
///
/// This struct encapsulates the mathematical logic for positioning cells,
/// determining cell indices from points, and validating grid bounds.
/// It provides a clean separation between layout calculations and rendering logic.
struct GridLayout {
    
    // MARK: - Properties
    
    /// The frame in which the grid is laid out.
    let frame: CGRect
    
    /// The scaling factor for the grid relative to the frame size.
    let scaleFactor: CGFloat
    
    /// The number of rows/columns in the grid.
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
    
    // MARK: - Public Methods
    
    /// Returns the center position for a given cell index.
    ///
    /// - Parameter cellIndex: The cell index (0-based, row-major order).
    /// - Returns: The center point of the cell in scene coordinates.
    func position(for cellIndex: Int) -> CGPoint {
        let row = cellIndex / dimension
        let column = cellIndex % dimension
        
        return CGPoint(
            x: gridOrigin.x + CGFloat(column) * cellSize.width + cellSize.width / 2,
            y: gridOrigin.y + CGFloat(row) * cellSize.height + cellSize.height / 2
        )
    }
    
    /// Returns the cell index for a given point in scene coordinates.
    ///
    /// - Parameter point: The point to test, in scene coordinates.
    /// - Returns: The cell index if the point is within the grid, otherwise `nil`.
    func cellIndex(at point: CGPoint) -> Int? {
        guard isPointInGrid(point) else { return nil }
        
        let column = Int((point.x - gridOrigin.x) / cellSize.width)
        let row = Int((point.y - gridOrigin.y) / cellSize.height)
        let index = row * dimension + column
        
        let maxIndex = dimension * dimension
        guard (0..<maxIndex).contains(index) else { return nil }
        return index
    }
    
    /// Returns the grid line positions for vertical lines.
    ///
    /// - Returns: An array of x-coordinates where vertical lines should be drawn.
    func verticalLinePositions() -> [CGFloat] {
        (1..<dimension).map { i in
            gridOrigin.x + CGFloat(i) * cellSize.width
        }
    }
    
    /// Returns the grid line positions for horizontal lines.
    ///
    /// - Returns: An array of y-coordinates where horizontal lines should be drawn.
    func horizontalLinePositions() -> [CGFloat] {
        (1..<dimension).map { i in
            gridOrigin.y + CGFloat(i) * cellSize.height
        }
    }
    
    // MARK: - Private Helpers
    
    /// Returns `true` if the point is within the grid bounds.
    ///
    /// - Parameter point: The point to test.
    /// - Returns: `true` if the point is inside the grid, `false` otherwise.
    private func isPointInGrid(_ point: CGPoint) -> Bool {
        let gridMaxX = gridOrigin.x + gridSize
        let gridMaxY = gridOrigin.y + gridSize
        
        return point.x >= gridOrigin.x && point.x <= gridMaxX &&
               point.y >= gridOrigin.y && point.y <= gridMaxY
    }
}
