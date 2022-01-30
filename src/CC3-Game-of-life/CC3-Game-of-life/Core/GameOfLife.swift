//
//  GameOfLife.swift
//  CC3-Game-of-life
//
//  Created by Juan Hurtado on 30/01/22.
//

import Foundation

struct GameOfLife {
    private let _rows = 80
    private let _cols = 40
    private let _alivePercentage = 0.1
    
    private(set) var universe: [[Cell]]
    
    init() {
        universe = []
        for _ in 0..<_rows {
            var row: [Cell] = []
            for _ in 0..<_cols {
                let alpha = Double.random(in: 0...1)
                let cell = Cell(state: alpha < _alivePercentage ? .alive : .dead)
                row.append(cell)
            }
            universe.append(row)
        }
    }
    
    private func _getNeighborsOf(row: Int, col: Int) -> [Cell] {
        var neighbors: [Cell] = []
        
        for rowOffset in -1...1 {
            for colOffset in -1...1 {
                if row == 0 && col == 0 {
                    continue
                }
                if row + rowOffset >= _rows || row + rowOffset < 0 {
                    continue
                }
                if col + colOffset >= _cols || col + colOffset < 0 {
                    continue
                }
                
                neighbors.append(universe[row + rowOffset][col + colOffset])
            }
        }
        
        return neighbors
    }
    
    mutating func evolve() {
        var universeCopy = universe
        
        for row in 0..<_rows {
            for col in 0..<_cols {
                let neighbors = _getNeighborsOf(row: row, col: col)
                let aliveNeighbors = neighbors.filter({ $0.state == .alive }).count
                
                // Any live cell with fewer than two live neighbours dies, as if by underpopulation.
                if aliveNeighbors < 3 && universe[row][col].state == .alive {
                    universeCopy[row][col].state = .dead
                    continue
                }
                
                // Any live cell with three or four live neighbours lives on to the next generation.
                if (aliveNeighbors == 3 || aliveNeighbors == 4) && universe[row][col].state == .alive {
                    universeCopy[row][col].state = .alive
                    continue
                }
                
                // Any live cell with more than three live neighbours dies, as if by overpopulation.
                if aliveNeighbors > 3 && universe[row][col].state == .alive {
                    universeCopy[row][col].state = .dead
                    continue
                }
                
                // Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction.
                if aliveNeighbors == 3 && universe[row][col].state == .dead {
                    universeCopy[row][col].state = .alive
                    continue
                }
            }
        }
        
        universe = universeCopy
    }
}
