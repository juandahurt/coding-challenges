//
//  Cell.swift
//  CC3-Game-of-life
//
//  Created by Juan Hurtado on 30/01/22.
//

import Foundation

struct Cell: Identifiable {
    var id: String = UUID().uuidString
    
    enum State {
        case dying, born, alive, dead
    }
    var state: State
}
