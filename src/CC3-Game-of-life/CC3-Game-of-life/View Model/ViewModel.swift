//
//  ViewModel.swift
//  CC3-Game-of-life
//
//  Created by Juan Hurtado on 30/01/22.
//

import Foundation

class ViewModel: ObservableObject {
    @Published private(set) var game = GameOfLife()
    
    func evolve() {
        game.evolve()
    }
}
