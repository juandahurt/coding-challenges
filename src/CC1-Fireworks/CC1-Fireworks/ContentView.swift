//
//  ContentView.swift
//  CC1-Fireworks
//
//  Created by Juan Hurtado on 27/01/22.
//

import SwiftUI

let screenHeight = UIScreen.main.bounds.height

extension CGVector {
    static func + (left: CGVector, right: CGVector) -> CGVector {
      return CGVector(dx: left.dx + right.dx, dy: left.dy + right.dy)
    }
}


struct Particle: Identifiable {
    var id: String = UUID().uuidString
    var pos: CGVector
    
    private let gravity = CGVector(dx: 0, dy: 0.003)
    var velocity = CGVector(dx: 0, dy: -11)
    private var acceleration: CGVector = .zero
    
    init(pos: CGPoint) {
        self.pos = CGVector(dx: pos.x, dy: pos.y)
    }
    
    mutating func update() {
        pos = pos + velocity
        acceleration = acceleration + gravity
        velocity = velocity + acceleration
    }
}

struct Framework: Identifiable {
    var id: String = UUID().uuidString
    var head: Particle
    var particles: [Particle]
    var exploded = false
    var opacity: Double = 1
    var color: Color
    
    init(at pos: CGPoint) {
        head = Particle(pos: pos)
        particles = []
        
        let colors: [Color] = [
            .white,
            .blue,
            .red,
            .green,
            .cyan
        ]
        color = colors.randomElement()!
    }
    
    mutating func update() {
        head.update()
        for index in particles.indices {
            particles[index].update()
        }
        if exploded {
            opacity -= 0.01
        }
    }
    
    mutating func explode() {
        let n = 100
        var count = 0
        
        while count < n {
            var particle = Particle(pos: CGPoint(x: head.pos.dx, y: head.pos.dy))
            let ranVelX: CGFloat = .random(in: -1.5...1.5)
            let ranVelY: CGFloat = .random(in: -1.5...1.5)
            particle.velocity = CGVector(dx: ranVelX, dy: ranVelY)
            particles.append(particle)
            count += 1
        }
        exploded = true
    }
}

class ViewModel: ObservableObject {
    @Published var frameworks: [Framework] = []
    
    init() {}
    
    func update() {
        let alpha = Double.random(in: 0...1)
        
        if alpha < 0.02 {
            let randomY: CGFloat = .random(in: screenHeight...screenHeight + 75)
            let randomX: CGFloat = .random(in: 0..<UIScreen.main.bounds.width)
            frameworks.append(Framework(at: CGPoint(x: randomX, y: randomY)))
        }
        
        for index in frameworks.indices {
            if frameworks[index].head.velocity.dy >= 1 && !frameworks[index].exploded {
                frameworks[index].explode()
            }
            frameworks[index].update()
        }
        
        frameworks.removeAll(where: { $0.opacity <= 0 })
    }
}

struct ContentView: View {
    let timer = Timer.publish(every: 0.015, on: .main, in: .common).autoconnect()
    @ObservedObject var viewModel = ViewModel()
    
    var frameworkView: some View {
        ForEach(viewModel.frameworks) { framework in
            ZStack {
                Circle()
                    .fill(framework.color)
                    .frame(width: 5, height: 5)
                    .position(x: framework.head.pos.dx, y: framework.head.pos.dy)
                    .opacity(framework.exploded ? 0 : 1)
                ForEach(framework.particles) { particle in
                    Circle()
                        .fill(framework.color)
                        .frame(width: 5, height: 5)
                        .position(x: particle.pos.dx, y: particle.pos.dy)
                        .opacity(framework.opacity)
                }
            }
        }
        
    }
    
    var body: some View {
        ZStack {
            Color.black
            frameworkView
                .onReceive(timer) { _ in
                    viewModel.update()
                }
        }
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
