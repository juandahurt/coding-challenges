//
//  ContentView.swift
//  CC3-Game-of-life
//
//  Created by Juan Hurtado on 30/01/22.
//

import SwiftUI

let screenWidth = UIScreen.main.bounds.width
let screenHeight = UIScreen.main.bounds.height


struct ContentView: View {
    @ObservedObject var viewModel = ViewModel()
    let timer = Timer.publish(every: 0.2, on: .main, in: .common).autoconnect()
    
    var grid: some View {
        VStack(spacing: 0) {
            ForEach(viewModel.game.universe.indices) { rowIndex in
                HStack(spacing: 0) {
                    ForEach(viewModel.game.universe[rowIndex]) { cell in
                        Rectangle()
                            .fill(cell.state == .alive ? .white : cell.state == .dying ? .red : cell.state == .born ? .blue : .black)
                    }
                }
            }
        }.onReceive(timer) { _ in
            viewModel.evolve()
        }
    }
    
    var body: some View {
        ZStack {
            Color.black
                .ignoresSafeArea()
            grid
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
