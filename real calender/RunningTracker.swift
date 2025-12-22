import SwiftUI
import CoreLocation
import Foundation

class RunningTracker: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var isRunning = false
    @Published var startTime: Date?
    @Published var elapsedTime: TimeInterval = 0
    @Published var distance: Double = 0
    @Published var currentPace: Double = 0
    @Published var locations: [CLLocation] = []
    
    private let locationManager = CLLocationManager()
    private var timer: Timer?
    private var lastLocation: CLLocation?
    
    var timeFormatted: String {
        let minutes = Int(elapsedTime) / 60
        let seconds = Int(elapsedTime) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
    
    var distanceFormatted: String {
        return String(format: "%.2f km", distance / 1000)
    }
    
    var paceFormatted: String {
        guard distance > 0 else { return "0:00/km" }
        let paceInSeconds = elapsedTime / (distance / 1000)
        let minutes = Int(paceInSeconds) / 60
        let seconds = Int(paceInSeconds) % 60
        return String(format: "%d:%02d/km", minutes, seconds)
    }
    
    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
    }
    
    func startRunning() {
        isRunning = true
        startTime = Date()
        elapsedTime = 0
        distance = 0
        locations = []
        lastLocation = nil
        
        locationManager.startUpdatingLocation()
        
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            self.elapsedTime += 1
        }
    }
    
    func stopRunning() {
        isRunning = false
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        if let lastLocation = lastLocation {
            let distanceDelta = location.distance(from: lastLocation)
            distance += distanceDelta
        }
        
        lastLocation = location
        self.locations.append(location)
        
        // Calculate current pace
        if elapsedTime > 0 && distance > 0 {
            currentPace = elapsedTime / (distance / 1000)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error)")
    }
}

// MARK: - Running Tracker View
struct RunningTrackerView: View {
    @EnvironmentObject var questManager: QuestManager
    @ObservedObject var runningTracker: RunningTracker
    @Binding var userProfile: UserProfile
    @Environment(\.dismiss) private var dismiss
    @State private var showingConfirmation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                // Header
                VStack(spacing: 16) {
                    Text("🏃‍♂️ 5K Run Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("Track your pace and time with GPS")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // Stats Display
                VStack(spacing: 24) {
                    // Time
                    VStack(spacing: 8) {
                        Text("Time")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        Text(runningTracker.timeFormatted)
                            .font(.system(size: 48, weight: .bold, design: .monospaced))
                            .foregroundColor(.primary)
                    }
                    
                    HStack(spacing: 40) {
                        // Distance
                        VStack(spacing: 8) {
                            Text("Distance")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(runningTracker.distanceFormatted)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                        
                        // Pace
                        VStack(spacing: 8) {
                            Text("Pace")
                                .font(.headline)
                                .foregroundColor(.secondary)
                            
                            Text(runningTracker.paceFormatted)
                                .font(.title)
                                .fontWeight(.bold)
                                .foregroundColor(.green)
                        }
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(16)
                
                // Control Button
                Button(action: {
                    if runningTracker.isRunning {
                        runningTracker.stopRunning()
                        if runningTracker.distance >= 5000 { // 5K completed
                            showingConfirmation = true
                        }
                    } else {
                        runningTracker.startRunning()
                    }
                }) {
                    HStack {
                        Image(systemName: runningTracker.isRunning ? "stop.fill" : "play.fill")
                            .font(.title2)
                        Text(runningTracker.isRunning ? "Stop Run" : "Start Run")
                            .font(.title2)
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(runningTracker.isRunning ? Color.red : Color.green)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .buttonStyle(.plain)
                
                // Progress towards 5K
                if runningTracker.distance > 0 {
                    VStack(spacing: 12) {
                        Text("Progress to 5K")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        
                        ProgressView(value: min(runningTracker.distance / 5000, 1.0))
                            .tint(.orange)
                            .scaleEffect(y: 2)
                        
                        Text("\(Int(runningTracker.distance))m / 5000m")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .background(Color.orange.opacity(0.1))
                    .cornerRadius(12)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("Run Tracker")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("Done") {
                    if runningTracker.isRunning {
                        runningTracker.stopRunning()
                    }
                    dismiss()
                }
            )
        }
        .alert("5K Completed!", isPresented: $showingConfirmation) {
            Button("Save Run") {
                let runRecord = userProfile.createRunRecord(
                    timeSec: Int(runningTracker.elapsedTime),
                    distance: runningTracker.distance
                )
                userProfile.addRun(runRecord)
                userProfile.incrementGraphUpdate(for: .running)
                userProfile.save()
                NotificationCenter.default.post(name: .profileUpdated, object: userProfile)
                if questManager.currentBatch == 5{
                    questManager.completeQuestWithIncremnetStaticForce(named: "Update Running graph or gym graph", num: 1, Quebatch: 5)
                }
                if questManager.currentBatch == 7{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 different graphs", num: 1, Quebatch: 7)
                }
                
                if questManager.currentBatch == 8{
                    questManager.completeQuestWithIncremnetStaticForce(named: "Update running graph", num: 1, Quebatch: 8)
                }
                
                if questManager.currentBatch == 10{
                    questManager.completeQuestWithIncremnetStaticForce(named: "Update Running graph or gym graph or Fill out Academic Graph if applicable", num: 1, Quebatch: 10)
                }
                
                if questManager.currentBatch == 12{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 different graphs", num: 1, Quebatch: 12)
                }
                
                if questManager.currentBatch == 13{
                    questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 13)
                }
                
                if questManager.currentBatch == 14{
                    questManager.completeQuestWithIncremnetForce(named: "Update BMI or Running graph", num: 1, Quebatch: 14)
                }
                
                if questManager.currentBatch == 18{
                    questManager.completeQuestWithIncremnetForce(named: "Update 3 different graphs", num: 1, Quebatch: 18)
                    questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 18)
                }
                
                if questManager.currentBatch == 20{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 1, Quebatch: 20)
                }
                
                if questManager.currentBatch == 21{
                    questManager.completeQuestWithIncremnetForce(named: "Update all unlocked graphs", num: 1, Quebatch: 21)
                }
                
                if questManager.currentBatch == 23{
                    questManager.completeQuestWithIncremnetForce(named: "BMI or running graph", num: 1, Quebatch: 23)
                }
                
                if questManager.currentBatch == 25{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 1, Quebatch: 25)
                    questManager.completeQuestWithIncremnetForce(named: "Update gym graph and Running graphs", num: 1, Quebatch: 25)
                }
                
                if questManager.currentBatch == 30{
                    questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 1, Quebatch: 30)
                }
                if questManager.currentBatch == 31{
                    questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 31)
                }
                
                if questManager.currentBatch == 33{
                    questManager.completeQuestWithIncremnetForce(named: "Update BMI and Running graphs", num: 1, Quebatch: 33)
                }
                
                if questManager.currentBatch == 36{
                    questManager.completeQuestWithIncremnetForce(named: "Update 3 graphs", num: 1, Quebatch: 36)
                }
                
                if questManager.currentBatch == 39{
                    questManager.completeQuestWithIncremnetForce(named: "Update all unlocked graphs", num: 1, Quebatch: 39)
                }
                if questManager.currentBatch == 42{
                    questManager.completeQuestWithIncremnetForce(named: "Update 4 graphs", num: 1, Quebatch: 42)
                }
                if questManager.currentBatch == 45{
                    questManager.completeQuestWithIncremnetForce(named: "Update 3 graphs", num: 1, Quebatch: 45)
                }
                
                if questManager.currentBatch == 46{
                    questManager.completeQuestWithIncremnetForce(named: "Update 4 different graphs", num: 1, Quebatch: 46)
                }
                
                if questManager.currentBatch == 50{
                    questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 1, Quebatch: 50)
                }
                
                if questManager.currentBatch == 52{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 1, Quebatch: 52)
                }
                
                if questManager.currentBatch == 53{
                    questManager.completeQuestWithIncremnetForce(named: "Update 4 graphs", num: 1, Quebatch: 53)
                }
                
                if questManager.currentBatch == 54{
                    questManager.completeQuestWithIncremnetForce(named: "Update one graph", num: 1, Quebatch: 54)
                }
                
                if questManager.currentBatch == 56{
                    questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 1, Quebatch: 56)
                }
                
                if questManager.currentBatch == 57{
                    questManager.completeQuestWithIncremnetForce(named: "Update 2 graphs", num: 1, Quebatch: 57)
                }
                
                if questManager.currentBatch == 58{
                    questManager.completeQuestWithIncremnetForce(named: "Update 1 graph", num: 1, Quebatch: 58)
                }
                
                if questManager.currentBatch == 59{
                    questManager.completeQuestWithIncremnetForce(named: "Update 5 different graphs", num: 1, Quebatch: 59)
                }
                
                if questManager.currentBatch == 61{
                    questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 1, Quebatch: 61)
                }
                
                if questManager.currentBatch == 63{
                    questManager.completeQuestWithIncremnetForce(named: "Update all graphs", num: 1, Quebatch: 63)
                }
                
                dismiss()
            }
            Button("Discard") {
                dismiss()
            }
        } message: {
            let runRecord = userProfile.createRunRecord(
                timeSec: Int(runningTracker.elapsedTime),
                distance: runningTracker.distance
            )
            
            if runRecord.isPersonalBest {
                Text("You completed 5K in \(runningTracker.timeFormatted)!\n🎉 NEW PERSONAL BEST!")
            } else if let improvement = runRecord.improvementFromPrevious {
                Text("You completed 5K in \(runningTracker.timeFormatted)!\n\(runRecord.improvementText)")
            } else {
                Text("You completed 5K in \(runningTracker.timeFormatted)!")
            }
        }
    }
}
