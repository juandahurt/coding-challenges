//
//  ContentView.swift
//  CC2-Random-Walker
//
//  Created by Juan Hurtado on 29/01/22.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height

let rows = 50
let cols = 30

let sizeOfCell = CGSize(width: screenWidth / CGFloat(cols), height: screenHeight / CGFloat(rows))

enum Direction {
    case up, down, left, right
}

struct Board {
    var positions: [[Bool]] = []
    var walkerPos = (x: 0, y: 0)
    var currDirection: Direction = .down
    let availableDirections: [Direction] = [.down, .left, .right, .up]
    var isStocked = false
    
    init() {
        for _ in 0..<rows {
            let row = [Bool](repeating: false, count: cols)
            positions.append(row)
        }
    }
    
    mutating func update() {
        for dir in availableDirections.shuffled() {
            if walkerCanMove(to: dir) {
                move(to: dir)
                positions[Int(walkerPos.x)][Int(walkerPos.y)] = true
                return
            }
        }
        isStocked = true
    }
        
    private func walkerCanMove(to direction: Direction) -> Bool {
        let newPos: (x: Int, y: Int)
        
        switch direction {
        case .up:
            newPos = (x: walkerPos.x, y: walkerPos.y - 1)
        case .down:
            newPos = (x: walkerPos.x, y: walkerPos.y + 1)
        case .left:
            newPos = (x: walkerPos.x - 1, y: walkerPos.y)
        case .right:
            newPos = (x: walkerPos.x + 1, y: walkerPos.y)
        }
        
        guard newPos.x < cols && newPos.x >= 0 && newPos.y >= 0 && newPos.y < rows  else {
            return false
        }
        return !positions[newPos.x][newPos.y]
    }
    
    private mutating func move(to direction: Direction) {
        currDirection = direction
        switch currDirection {
        case .up:
            walkerPos.y -= 1
        case .down:
            walkerPos.y += 1
        case .left:
            walkerPos.x -= 1
        case .right:
            walkerPos.x += 1
        }
    }
}

class ViewModel: ObservableObject {
    @Published var board: Board
    
    init() {
        board = Board()
    }
    
    func update() {
        board.update()
    }
}

struct ContentView: View {
    let timer = Timer.publish(every: 0.1, on: .main, in: .common).autoconnect()
    
    @ObservedObject var viewModel = ViewModel()
    
    func cell(row: Int, col: Int) -> some View {
        let pos = (x: row, y: col)
        let hasBeenWalkedOn = viewModel.board.positions[row][col]
        let color: Color
        if pos == viewModel.board.walkerPos {
            color = .red
        } else {
            color = .white.opacity(hasBeenWalkedOn ? 0.2 : 0.1)
        }
        
        return Rectangle()
            .fill(color)
    }
    
    var board: some View {
        VStack(spacing: 0) {
            ForEach(0..<rows) { row in
                HStack(spacing: 0) {
                    ForEach(0..<cols) { col in
                        cell(row: row, col: col)
                    }
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            board
            Text("I'm stuck!")
                .font(.largeTitle)
                .foregroundColor(.white)
                .opacity(viewModel.board.isStocked ? 1 : 0)
        }.onReceive(timer) { _ in
            viewModel.update()
            if viewModel.board.isStocked {
                timer.upstream.connect().cancel()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
