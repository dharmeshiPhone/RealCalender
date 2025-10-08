import SwiftUI
import SceneKit

struct Realistic3DBodyView: View {
    let userProfile: UserProfile
    @State private var rotationAngle: Float = 0
    @State private var isRotating = false
    @State private var selectedBodyPart: String? = nil
    @State private var showingMeasurements = true
    @State private var cameraDistance: Float = 8.0

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(spacing: 12) {
                Text("Your 3D Body Model")
                    .font(.largeTitle)
                    .fontWeight(.bold)

                Text("Realistic human body visualization")
                    .font(.subheadline)
                    .foregroundColor(.secondary)

                // Model completeness indicator
                HStack {
                    Image(systemName: userProfile.hasBasicMeasurements ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundColor(userProfile.hasBasicMeasurements ? .green : .orange)

                    Text(userProfile.hasBasicMeasurements ? "High Fidelity Model" : "Add measurements for better accuracy")
                        .font(.caption)
                        .foregroundColor(userProfile.hasBasicMeasurements ? .green : .orange)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color(.systemGray6))
                .cornerRadius(20)
            }
            .padding()

            // 3D Scene
            GeometryReader { geometry in
                ZStack {
                    // Professional gradient background
                    LinearGradient(
                        gradient: Gradient(colors: [
                            Color(red: 0.15, green: 0.15, blue: 0.2),
                            Color(red: 0.1, green: 0.1, blue: 0.15),
                            Color(red: 0.05, green: 0.05, blue: 0.1)
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )

                    // Advanced 3D SceneKit View
                    Advanced3DSceneView(
                        userProfile: userProfile,
                        rotationAngle: $rotationAngle,
                        selectedBodyPart: $selectedBodyPart,
                        cameraDistance: $cameraDistance
                    )
                    .clipped()
                    .cornerRadius(20)
                    .shadow(color: .black.opacity(0.3), radius: 15, x: 0, y: 10)

                    // Professional measurement overlays
                    if showingMeasurements {
                        ProfessionalMeasurementOverlays(
                            userProfile: userProfile,
                            geometry: geometry,
                            rotationAngle: rotationAngle
                        )
                    }
                }
            }
            .padding()

            // Professional Controls
            VStack(spacing: 20) {
                // Rotation and camera controls
                HStack(spacing: 30) {
                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            rotationAngle -= Float.pi / 4
                        }
                    }) {
                        Image(systemName: "rotate.left")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                    }

                    Button(action: {
                        isRotating.toggle()
                    }) {
                        Image(systemName: isRotating ? "pause.fill" : "play.fill")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.green, Color.green.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                    }

                    Button(action: {
                        withAnimation(.easeInOut(duration: 0.5)) {
                            rotationAngle += Float.pi / 4
                        }
                    }) {
                        Image(systemName: "rotate.right")
                            .font(.system(size: 20, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 50, height: 50)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.blue, Color.blue.opacity(0.8)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                    }
                }

                // Camera zoom slider
                VStack(spacing: 8) {
                    Text("Camera Distance")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Slider(value: $cameraDistance, in: 5...15, step: 0.5)
                        .tint(.blue)
                }
                .padding(.horizontal)

                // Toggle measurements with better design
                HStack {
                    Text("Measurements")
                        .font(.subheadline)
                        .fontWeight(.medium)

                    Spacer()

                    Toggle("", isOn: $showingMeasurements)
                        .labelsHidden()
                        .toggleStyle(SwitchToggleStyle(tint: .blue))
                }
                .padding(.horizontal)

                // Body part selection with better UI
                if let selectedPart = selectedBodyPart {
                    VStack(spacing: 12) {
                        HStack {
                            Image(systemName: "target")
                                .foregroundColor(.blue)

                            Text("Selected: \(selectedPart)")
                                .font(.headline)
                                .fontWeight(.semibold)
                        }

                        if let measurement = getMeasurementForBodyPart(selectedPart) {
                            HStack {
                                Text(measurement.label)
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Spacer()

                                Text("\(measurement.value, specifier: "%.1f") \(measurement.unit)")
                                    .font(.title3)
                                    .fontWeight(.bold)
                                    .foregroundColor(.primary)
                            }
                        }
                    }
                    .padding()
                    .background(
                        LinearGradient(
                            gradient: Gradient(colors: [
                                Color.blue.opacity(0.1),
                                Color.blue.opacity(0.05)
                            ]),
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .cornerRadius(16)
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue.opacity(0.3), lineWidth: 1)
                    )
                }
            }
            .padding()
            .background(Color(.systemGray6))
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if isRotating {
                startAutoRotation()
            }
        }
        .onDisappear {
            stopAutoRotation()
        }
        .onChange(of: isRotating) { _, newValue in
            if newValue {
                startAutoRotation()
            } else {
                stopAutoRotation()
            }
        }
    }

    private func startAutoRotation() {
        Timer.scheduledTimer(withTimeInterval: 0.016, repeats: true) { timer in
            if !isRotating {
                timer.invalidate()
                return
            }
            rotationAngle += 0.005
        }
    }

    private func stopAutoRotation() {
        isRotating = false
    }

    private func getMeasurementForBodyPart(_ bodyPart: String) -> (label: String, value: Double, unit: String)? {
        switch bodyPart.lowercased() {
        case "head":
            return ("Head circumference", userProfile.heightCM / 7.5, "cm")
        case "neck":
            return ("Neck circumference", userProfile.waistCM * 0.5, "cm")
        case "torso", "chest":
            return ("Chest circumference", userProfile.measurements["Chest"] ?? userProfile.waistCM * 1.2, "cm")
        case "waist":
            return ("Waist circumference", userProfile.waistCM, "cm")
        case "left arm", "right arm":
            return ("Bicep circumference", userProfile.measurements["Biceps"] ?? userProfile.waistCM * 0.4, "cm")
        case "left leg", "right leg":
            return ("Thigh circumference", userProfile.measurements["Thigh"] ?? userProfile.waistCM * 0.7, "cm")
        default:
            return nil
        }
    }
}

// MARK: - Advanced 3D Scene View
struct Advanced3DSceneView: UIViewRepresentable {
    let userProfile: UserProfile
    @Binding var rotationAngle: Float
    @Binding var selectedBodyPart: String?
    @Binding var cameraDistance: Float

    func makeUIView(context: Context) -> SCNView {
        let sceneView = SCNView()
        sceneView.scene = createAdvancedHumanScene()
        sceneView.backgroundColor = UIColor.clear
        sceneView.allowsCameraControl = true
        sceneView.autoenablesDefaultLighting = false
        sceneView.antialiasingMode = .multisampling4X

        // Enhanced rendering settings
        sceneView.isJitteringEnabled = true
        sceneView.preferredFramesPerSecond = 60

        // Add tap gesture
        let tapGesture = UITapGestureRecognizer(target: context.coordinator, action: #selector(Coordinator.handleTap(_:)))
        sceneView.addGestureRecognizer(tapGesture)

        return sceneView
    }

    func updateUIView(_ uiView: SCNView, context: Context) {
        // Update rotation
        if let rootNode = uiView.scene?.rootNode.childNode(withName: "humanBody", recursively: false) {
            rootNode.rotation = SCNVector4(0, 1, 0, rotationAngle)
        }

        // Update camera distance
        if let cameraNode = uiView.scene?.rootNode.childNode(withName: "camera", recursively: false) {
            cameraNode.position = SCNVector3(0, 0, cameraDistance)
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject {
        var parent: Advanced3DSceneView

        init(_ parent: Advanced3DSceneView) {
            self.parent = parent
        }

        @objc func handleTap(_ gesture: UITapGestureRecognizer) {
            let sceneView = gesture.view as! SCNView
            let location = gesture.location(in: sceneView)

            let hitResults = sceneView.hitTest(location, options: nil)
            if let result = hitResults.first {
                parent.selectedBodyPart = result.node.name ?? "Unknown"
            }
        }
    }

    private func createAdvancedHumanScene() -> SCNScene {
        let scene = SCNScene()

        // Create realistic human body
        let humanBody = createRealisticHumanBody()
        humanBody.name = "humanBody"
        scene.rootNode.addChildNode(humanBody)

        // Professional lighting setup
        setupProfessionalLighting(scene: scene)

        // Set up camera
        let camera = SCNCamera()
        camera.fieldOfView = 45
        camera.zNear = 0.1
        camera.zFar = 100

        let cameraNode = SCNNode()
        cameraNode.camera = camera
        cameraNode.position = SCNVector3(0, 0, cameraDistance)
        cameraNode.name = "camera"
        scene.rootNode.addChildNode(cameraNode)

        return scene
    }

    private func createRealisticHumanBody() -> SCNNode {
        let bodyNode = SCNNode()

        // Calculate realistic proportions
        let heightFactor = Float(userProfile.heightCM / 175.0)
        let weightFactor = Float(userProfile.weightKG / 70.0)
        let waistFactor = Float(userProfile.waistCM / 80.0)

        // Create body parts with realistic proportions
        let head = createRealisticHead(heightFactor: heightFactor)
        let neck = createRealisticNeck(heightFactor: heightFactor)
        let torso = createRealisticTorso(heightFactor: heightFactor, weightFactor: weightFactor, waistFactor: waistFactor)
        let waist = createRealisticWaist(heightFactor: heightFactor, waistFactor: waistFactor)
        let leftArm = createRealisticArm(heightFactor: heightFactor, weightFactor: weightFactor, isLeft: true)
        let rightArm = createRealisticArm(heightFactor: heightFactor, weightFactor: weightFactor, isLeft: false)
        let leftLeg = createRealisticLeg(heightFactor: heightFactor, weightFactor: weightFactor, isLeft: true)
        let rightLeg = createRealisticLeg(heightFactor: heightFactor, weightFactor: weightFactor, isLeft: false)

        // Position with realistic proportions
        head.position = SCNVector3(0, 3.2 * heightFactor, 0)
        neck.position = SCNVector3(0, 2.8 * heightFactor, 0)
        torso.position = SCNVector3(0, 1.5 * heightFactor, 0)
        waist.position = SCNVector3(0, 0.3 * heightFactor, 0)
        leftArm.position = SCNVector3(-0.8 * heightFactor, 2.0 * heightFactor, 0)
        rightArm.position = SCNVector3(0.8 * heightFactor, 2.0 * heightFactor, 0)
        leftLeg.position = SCNVector3(-0.15 * heightFactor, -1.5 * heightFactor, 0)
        rightLeg.position = SCNVector3(0.15 * heightFactor, -1.5 * heightFactor, 0)

        // Add all parts
        bodyNode.addChildNode(head)
        bodyNode.addChildNode(neck)
        bodyNode.addChildNode(torso)
        bodyNode.addChildNode(waist)
        bodyNode.addChildNode(leftArm)
        bodyNode.addChildNode(rightArm)
        bodyNode.addChildNode(leftLeg)
        bodyNode.addChildNode(rightLeg)

        return bodyNode
    }

    private func createRealisticHead(heightFactor: Float) -> SCNNode {
        let headGeometry = SCNSphere(radius: CGFloat(0.25 * heightFactor))
        let headMaterial = createSkinMaterial()
        headGeometry.materials = [headMaterial]

        let headNode = SCNNode(geometry: headGeometry)
        headNode.name = "Head"
        return headNode
    }

    private func createRealisticNeck(heightFactor: Float) -> SCNNode {
        let neckGeometry = SCNCylinder(radius: CGFloat(0.08 * heightFactor), height: CGFloat(0.3 * heightFactor))
        let neckMaterial = createSkinMaterial()
        neckGeometry.materials = [neckMaterial]

        let neckNode = SCNNode(geometry: neckGeometry)
        neckNode.name = "Neck"
        return neckNode
    }

    private func createRealisticTorso(heightFactor: Float, weightFactor: Float, waistFactor: Float) -> SCNNode {
        // Create a more realistic torso shape using a tapered cylinder
        let torsoGeometry = SCNBox(
            width: CGFloat(0.35 * weightFactor),
            height: CGFloat(0.8 * heightFactor),
            length: CGFloat(0.2 * waistFactor),
            chamferRadius: CGFloat(0.05 * heightFactor)
        )
        let torsoMaterial = createSkinMaterial()
        torsoGeometry.materials = [torsoMaterial]

        let torsoNode = SCNNode(geometry: torsoGeometry)
        torsoNode.name = "Torso"
        return torsoNode
    }

    private func createRealisticWaist(heightFactor: Float, waistFactor: Float) -> SCNNode {
        let waistGeometry = SCNBox(
            width: CGFloat(0.3 * waistFactor),
            height: CGFloat(0.4 * heightFactor),
            length: CGFloat(0.18 * waistFactor),
            chamferRadius: CGFloat(0.05 * heightFactor)
        )
        let waistMaterial = createSkinMaterial()
        waistGeometry.materials = [waistMaterial]

        let waistNode = SCNNode(geometry: waistGeometry)
        waistNode.name = "Waist"
        return waistNode
    }

    private func createRealisticArm(heightFactor: Float, weightFactor: Float, isLeft: Bool) -> SCNNode {
        let armNode = SCNNode()

        // Upper arm
        let upperArmGeometry = SCNCylinder(radius: CGFloat(0.06 * weightFactor), height: CGFloat(0.7 * heightFactor))
        let upperArmMaterial = createSkinMaterial()
        upperArmGeometry.materials = [upperArmMaterial]

        let upperArmNode = SCNNode(geometry: upperArmGeometry)
        upperArmNode.name = isLeft ? "Left Arm" : "Right Arm"

        // Lower arm (forearm)
        let lowerArmGeometry = SCNCylinder(radius: CGFloat(0.05 * weightFactor), height: CGFloat(0.6 * heightFactor))
        let lowerArmMaterial = createSkinMaterial()
        lowerArmGeometry.materials = [lowerArmMaterial]

        let lowerArmNode = SCNNode(geometry: lowerArmGeometry)
        lowerArmNode.position = SCNVector3(0, -0.65 * heightFactor, 0)

        // Hand
        let handGeometry = SCNSphere(radius: CGFloat(0.04 * heightFactor))
        let handMaterial = createSkinMaterial()
        handGeometry.materials = [handMaterial]

        let handNode = SCNNode(geometry: handGeometry)
        handNode.position = SCNVector3(0, -0.95 * heightFactor, 0)

        armNode.addChildNode(upperArmNode)
        armNode.addChildNode(lowerArmNode)
        armNode.addChildNode(handNode)

        return armNode
    }

    private func createRealisticLeg(heightFactor: Float, weightFactor: Float, isLeft: Bool) -> SCNNode {
        let legNode = SCNNode()

        // Thigh
        let thighGeometry = SCNCylinder(radius: CGFloat(0.08 * weightFactor), height: CGFloat(0.9 * heightFactor))
        let thighMaterial = createSkinMaterial()
        thighGeometry.materials = [thighMaterial]

        let thighNode = SCNNode(geometry: thighGeometry)
        thighNode.name = isLeft ? "Left Leg" : "Right Leg"

        // Calf
        let calfGeometry = SCNCylinder(radius: CGFloat(0.06 * weightFactor), height: CGFloat(0.8 * heightFactor))
        let calfMaterial = createSkinMaterial()
        calfGeometry.materials = [calfMaterial]

        let calfNode = SCNNode(geometry: calfGeometry)
        calfNode.position = SCNVector3(0, -0.85 * heightFactor, 0)

        // Foot
        let footGeometry = SCNBox(width: CGFloat(0.1 * heightFactor), height: CGFloat(0.05 * heightFactor), length: CGFloat(0.2 * heightFactor), chamferRadius: 0.01)
        let footMaterial = createSkinMaterial()
        footGeometry.materials = [footMaterial]

        let footNode = SCNNode(geometry: footGeometry)
        footNode.position = SCNVector3(0, -1.3 * heightFactor, 0.1 * heightFactor)

        legNode.addChildNode(thighNode)
        legNode.addChildNode(calfNode)
        legNode.addChildNode(footNode)

        return legNode
    }

    private func createSkinMaterial() -> SCNMaterial {
        let material = SCNMaterial()
        material.diffuse.contents = UIColor(red: 0.92, green: 0.8, blue: 0.7, alpha: 1.0) // Realistic skin tone
        material.specular.contents = UIColor.white
        material.shininess = 0.1
        material.roughness.contents = 0.8
        material.metalness.contents = 0.0
        return material
    }

    private func setupProfessionalLighting(scene: SCNScene) {
        // Key light
        let keyLight = SCNLight()
        keyLight.type = .directional
        keyLight.color = UIColor.white
        keyLight.intensity = 1000
        keyLight.shadowMode = .deferred
        keyLight.shadowColor = UIColor.black.withAlphaComponent(0.5)

        let keyLightNode = SCNNode()
        keyLightNode.light = keyLight
        keyLightNode.position = SCNVector3(5, 10, 5)
        keyLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(keyLightNode)

        // Fill light
        let fillLight = SCNLight()
        fillLight.type = .directional
        fillLight.color = UIColor.white
        fillLight.intensity = 400

        let fillLightNode = SCNNode()
        fillLightNode.light = fillLight
        fillLightNode.position = SCNVector3(-5, 5, 5)
        fillLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(fillLightNode)

        // Ambient light
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        ambientLight.color = UIColor.lightGray
        ambientLight.intensity = 200

        let ambientLightNode = SCNNode()
        ambientLightNode.light = ambientLight
        scene.rootNode.addChildNode(ambientLightNode)

        // Rim light
        let rimLight = SCNLight()
        rimLight.type = .directional
        rimLight.color = UIColor.cyan
        rimLight.intensity = 300

        let rimLightNode = SCNNode()
        rimLightNode.light = rimLight
        rimLightNode.position = SCNVector3(0, 2, -5)
        rimLightNode.look(at: SCNVector3(0, 0, 0))
        scene.rootNode.addChildNode(rimLightNode)
    }
}

// MARK: - Professional Measurement Overlays
struct ProfessionalMeasurementOverlays: View {
    let userProfile: UserProfile
    let geometry: GeometryProxy
    let rotationAngle: Float

    var body: some View {
        ZStack {
            // Height measurement with professional styling
            if userProfile.heightCM > 0 {
                ProfessionalMeasurementLabel(
                    text: "\(Int(userProfile.heightCM)) cm",
                    subtitle: "Height",
                    color: .blue
                )
                .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.3)
            }

            // Waist measurement
            if userProfile.waistCM > 0 {
                ProfessionalMeasurementLabel(
                    text: "\(Int(userProfile.waistCM)) cm",
                    subtitle: "Waist",
                    color: .orange
                )
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.6)
            }

            // Weight display
            if userProfile.weightKG > 0 {
                ProfessionalMeasurementLabel(
                    text: "\(Int(userProfile.weightKG)) kg",
                    subtitle: "Weight",
                    color: .green
                )
                .position(x: geometry.size.width * 0.9, y: geometry.size.height * 0.2)
            }

            // BMI display
            if userProfile.bmi > 0 {
                ProfessionalMeasurementLabel(
                    text: String(format: "%.1f", userProfile.bmi),
                    subtitle: "BMI",
                    color: .purple
                )
                .position(x: geometry.size.width * 0.1, y: geometry.size.height * 0.8)
            }
        }
    }
}

struct ProfessionalMeasurementLabel: View {
    let text: String
    let subtitle: String
    let color: Color

    var body: some View {
        VStack(spacing: 4) {
            Text(text)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Text(subtitle)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.8))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            LinearGradient(
                gradient: Gradient(colors: [color, color.opacity(0.8)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.3), radius: 8, x: 0, y: 4)
    }
}

#Preview {
    Realistic3DBodyView(userProfile: UserProfile(
        name: "Test User", 
        age: 20, 
        heightCM: 175, 
        weightKG: 70, 
        measurements: ["chest": 100, "waist": 80, "hips": 95], 
        level: 1, 
        xp: 0, 
        stats: []
    ))
}