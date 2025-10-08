import SwiftUI

struct CosmicBackgroundView: View {
    @State private var stars: [CosmicStar] = []
    @State private var nebulaClouds: [NebulaPatch] = []
    @State private var galaxySpirals: [GalaxySpiral] = []
    @State private var cosmicParticles: [CosmicParticle] = []
    @State private var backgroundOpacity: Double = 0.0
    @State private var isAnimating = true

    var body: some View {
        ZStack {
            // Dark space background
            Color.black
                .edgesIgnoringSafeArea(.all)
            
            // Nebula clouds
            NebulaCloudsView(nebulaClouds: nebulaClouds)
            
            // Galaxy spirals
            GalaxySpiralsView(galaxySpirals: galaxySpirals)
            
            // Stars
            StarsView(stars: stars)
            
            // Cosmic particles
            CosmicParticlesView(cosmicParticles: cosmicParticles)
        }
        .onAppear {
            setupCosmicElements()
            startAnimations()
        }
    }
    
    private func setupCosmicElements() {
        // Create stars
        stars = (0..<100).map { _ in
            CosmicStar(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 0.5...2.0),
                color: [.white, .yellow, .blue].randomElement() ?? .white,
                opacity: Double.random(in: 0.3...1.0),
                speed: Double.random(in: 0.1...0.5),
                twinkle: 0.0
            )
        }
        
        // Create nebula clouds
        nebulaClouds = (0..<5).map { _ in
            NebulaPatch(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 100...300),
                color: [Color.purple, Color.blue, Color.pink, Color.orange].randomElement() ?? Color.purple,
                drift: Double.random(in: 0.01...0.05),
                rotation: Double.random(in: 0...360)
            )
        }
        
        // Create galaxy spirals
        galaxySpirals = (0..<3).map { _ in
            GalaxySpiral(
                center: CGPoint(
                    x: CGFloat.random(in: 100...(UIScreen.main.bounds.width - 100)),
                    y: CGFloat.random(in: 100...(UIScreen.main.bounds.height - 100))
                ),
                innerRadius: Double.random(in: 30...60),
                outerRadius: Double.random(in: 100...200),
                arms: Int.random(in: 2...4),
                color: [Color.blue, Color.purple, Color.cyan].randomElement() ?? Color.blue,
                rotationSpeed: Double.random(in: 0.1...0.5)
            )
        }
        
        // Create cosmic particles
        cosmicParticles = (0..<50).map { _ in
            CosmicParticle(
                position: CGPoint(
                    x: CGFloat.random(in: 0...UIScreen.main.bounds.width),
                    y: CGFloat.random(in: 0...UIScreen.main.bounds.height)
                ),
                size: CGFloat.random(in: 1.0...3.0),
                color: [Color.white, Color.yellow, Color.cyan].randomElement() ?? Color.white,
                opacity: Double.random(in: 0.2...0.8),
                frequency: Double.random(in: 0.5...2.0),
                amplitude: CGFloat.random(in: 5.0...20.0)
            )
        }
    }
    
    private func startAnimations() {
        withAnimation(.easeInOut(duration: 2.0)) {
            backgroundOpacity = 1.0
        }
    }
}

struct StarsView: View {
    let stars: [CosmicStar]
    @State private var twinklingStars: [CosmicStar] = []
    
    var body: some View {
        ZStack {
            ForEach(stars) { star in
                Circle()
                    .fill(star.color)
                    .frame(width: star.size, height: star.size)
                    .position(star.position)
                    .opacity(star.opacity + (twinklingStars.contains { $0.id == star.id } ? 0.5 : 0.0))
                    .onAppear {
                        startTwinkling(for: star)
                    }
            }
        }
    }
    
    private func startTwinkling(for star: CosmicStar) {
        DispatchQueue.main.asyncAfter(deadline: .now() + Double.random(in: 0...5)) {
            withAnimation(.easeInOut(duration: 0.5)) {
                if let index = twinklingStars.firstIndex(where: { $0.id == star.id }) {
                    twinklingStars.remove(at: index)
                } else {
                    twinklingStars.append(star)
                }
            }
            
            startTwinkling(for: star) // Repeat
        }
    }
}

struct NebulaCloudsView: View {
    let nebulaClouds: [NebulaPatch]
    
    var body: some View {
        ZStack {
            ForEach(nebulaClouds) { nebula in
                Ellipse()
                    .fill(createNebulaGradient(for: nebula))
                    .frame(width: nebula.size, height: nebula.size * 0.6)
                    .position(nebula.position)
                    .rotationEffect(.degrees(nebula.rotation))
                    .blendMode(.screen)
            }
        }
    }
    
    private func createNebulaGradient(for nebula: NebulaPatch) -> RadialGradient {
        RadialGradient(
            gradient: Gradient(colors: [
                nebula.color.opacity(0.8),
                nebula.color.opacity(0.4),
                nebula.color.opacity(0.1),
                .clear
            ]),
            center: .center,
            startRadius: 0,
            endRadius: nebula.size / 2
        )
    }
}

struct GalaxySpiralsView: View {
    let galaxySpirals: [GalaxySpiral]
    @State private var rotations: [UUID: Double] = [:]
    
    var body: some View {
        ZStack {
            ForEach(galaxySpirals) { galaxy in
                GalaxySpiralArmView(galaxy: galaxy)
                    .rotationEffect(.degrees(rotations[galaxy.id] ?? 0.0))
                    .onAppear {
                        animateGalaxy(galaxy)
                    }
            }
        }
    }
    
    private func animateGalaxy(_ galaxy: GalaxySpiral) {
        withAnimation(.linear(duration: 10.0 / galaxy.rotationSpeed).repeatForever(autoreverses: false)) {
            rotations[galaxy.id] = (rotations[galaxy.id] ?? 0.0) + 360.0
        }
    }
}

struct GalaxySpiralArmView: View {
    let galaxy: GalaxySpiral
    
    var body: some View {
        ZStack {
            ForEach(0..<galaxy.arms, id: \.self) { arm in
                let angle = Double(arm) * (360.0 / Double(galaxy.arms))
                Path { path in
                    let center = galaxy.center
                    let innerRadius = galaxy.innerRadius
                    let outerRadius = galaxy.outerRadius
                    
                    path.move(to: CGPoint(
                        x: center.x + CGFloat(innerRadius * cos(angle * .pi / 180)),
                        y: center.y + CGFloat(innerRadius * sin(angle * .pi / 180))
                    ))
                    
                    let controlPoint1 = CGPoint(
                        x: center.x + CGFloat(innerRadius * 1.5 * cos((angle + 30) * .pi / 180)),
                        y: center.y + CGFloat(innerRadius * 1.5 * sin((angle + 30) * .pi / 180))
                    )
                    
                    let controlPoint2 = CGPoint(
                        x: center.x + CGFloat(outerRadius * 0.8 * cos((angle + 90) * .pi / 180)),
                        y: center.y + CGFloat(outerRadius * 0.8 * sin((angle + 90) * .pi / 180))
                    )
                    
                    let endPoint = CGPoint(
                        x: center.x + CGFloat(outerRadius * cos((angle + 120) * .pi / 180)),
                        y: center.y + CGFloat(outerRadius * sin((angle + 120) * .pi / 180))
                    )
                    
                    path.addCurve(
                        to: endPoint,
                        control1: controlPoint1,
                        control2: controlPoint2
                    )
                }
                .stroke(
                    galaxy.color.opacity(0.6),
                    lineWidth: 2
                )
                .shadow(color: galaxy.color, radius: 5)
            }
        }
    }
}

struct CosmicParticlesView: View {
    let cosmicParticles: [CosmicParticle]
    @State private var animatedParticles: [UUID: CGPoint] = [:]
    
    var body: some View {
        ZStack {
            ForEach(cosmicParticles) { particle in
                Circle()
                    .fill(particle.color)
                    .frame(width: particle.size, height: particle.size)
                    .position(animatedParticles[particle.id] ?? particle.position)
                    .opacity(particle.opacity)
                    .onAppear {
                        animateParticle(particle)
                    }
            }
        }
    }
    
    private func animateParticle(_ particle: CosmicParticle) {
        let newPosition = CGPoint(
            x: particle.position.x + CGFloat(sin(Date().timeIntervalSince1970 * particle.frequency) * particle.amplitude),
            y: particle.position.y + CGFloat(cos(Date().timeIntervalSince1970 * particle.frequency) * particle.amplitude)
        )
        
        withAnimation(.easeInOut(duration: 0.1)) {
            animatedParticles[particle.id] = newPosition
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            animateParticle(particle)
        }
    }
}