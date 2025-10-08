import SwiftUI

struct BadgesView: View {
    @EnvironmentObject var achievementManager: AchievementManager
    @State private var selectedAchievement: Achievement?
    @State private var showingAchievementDetail = false
    @State private var showLevelUpCelebration = false
    @State private var levelUpAchievement: Achievement?
    
    // Crown animation states
    @State private var crownScale: CGFloat = 0.1
    @State private var crownRotation: Double = 0
    @State private var overlayOpacity: Double = 0
    @State private var glowOpacity: Double = 0.0
    @State private var pulseScale: CGFloat = 1.0
    @State private var clickCount = 0
    @State private var showCongratulationsText = false
    
    var body: some View {
        ZStack {
            badgesMainContent
            
            if showLevelUpCelebration {
                levelUpCelebrationOverlay
            }
        }
        .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("AchievementLevelUp"))) { notification in
            handleLevelUpNotification(notification)
        }
        .onAppear {
            handleViewAppear()
        }
    }
    
    // MARK: - Main Content View
    private var badgesMainContent: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    headerSection
                    testingControlsSection
                    achievementsContent
                }
            }
            .navigationTitle("Badges")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingAchievementDetail) {
                if let achievement = selectedAchievement {
                    AchievementDetailView(achievement: achievement, achievementManager: achievementManager)
                }
            }
        }
        .blur(radius: showLevelUpCelebration ? 10 : 0)
        .disabled(showLevelUpCelebration)
    }
    
    // MARK: - Header Section
    private var headerSection: some View {
        VStack(spacing: 8) {
            Image(systemName: "trophy.fill")
                .font(.system(size: 40))
                .foregroundColor(.yellow)
            
            Text("Your Achievements")
                .font(.title)
                .fontWeight(.bold)
            
            Text("Level up your badges by using the app!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - Testing Controls Section
    private var testingControlsSection: some View {
        VStack(spacing: 12) {
            Text("Testing Controls")
                .font(.headline)
                .fontWeight(.semibold)
                .foregroundColor(.orange)
            
            testingButtonsRow
            
            if let calendarAchievement = achievementManager.getCalendarAchievement() {
                achievementStatusView(calendarAchievement)
            }
        }
        .padding()
        .background(Color.orange.opacity(0.1))
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    // MARK: - Testing Buttons Row
    private var testingButtonsRow: some View {
        HStack(spacing: 12) {
            Button("Add Progress") {
                achievementManager.updateCalendarProgress()
                print("📈 Manual progress added")
            }
            .buttonStyle(.borderedProminent)
            .controlSize(.small)
            
            Button("Force Level Up") {
                handleForceLevelUp()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
            
            Button("Reset Achievement") {
                handleResetAchievement()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.red)
            
            Button("Test Crown Animation") {
                handleTestCrownAnimation()
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
            .foregroundColor(.green)
        }
    }
    
    // MARK: - Achievement Status View
    private func achievementStatusView(_ achievement: Achievement) -> some View {
        VStack(spacing: 4) {
            Text("Calendar Achievement Status")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            Text("Level \(achievement.level) • Progress: \(achievement.currentProgress)/\(achievement.maxProgress)")
                .font(.caption2)
                .foregroundColor(.green)
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.green.opacity(0.1))
                .cornerRadius(8)
        }
    }
    
    // MARK: - Achievements Content
    private var achievementsContent: some View {
        Group {
            if achievementManager.achievements.isEmpty {
                emptyStateView
            } else {
                achievementsGrid
            }
        }
    }
    
    // MARK: - Empty State View
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "star.circle")
                .font(.system(size: 60))
                .foregroundColor(.gray)
            
            Text("No Achievements Yet")
                .font(.headline)
                .foregroundColor(.secondary)
            
            Text("Complete your calendar setup to unlock your first achievement!")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
        .padding(.vertical, 40)
    }
    
    // MARK: - Achievements Grid
    private var achievementsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible()),
            GridItem(.flexible())
        ], spacing: 16) {
            ForEach(achievementManager.achievements) { achievement in
                AchievementBadgeCard(achievement: achievement) {
                    selectedAchievement = achievement
                    showingAchievementDetail = true
                }
            }
        }
        .padding(.horizontal)
    }
    
    // MARK: - Level Up Celebration Overlay
    private var levelUpCelebrationOverlay: some View {
        ZStack {
            Color.black
                .opacity(overlayOpacity * 0.9)
                .ignoresSafeArea()
            
            VStack {
                Spacer()
                crownAnimationSection
                Spacer()
                celebrationTextSection
                Spacer()
            }
        }
        .opacity(overlayOpacity)
    }
    
    // MARK: - Crown Animation Section
    private var crownAnimationSection: some View {
        ZStack {
            crownGlowEffects
            crownImage
        }
    }
    
    // MARK: - Crown Glow Effects
    private var crownGlowEffects: some View {
        ZStack {
            // Gold ring animation around crown
            Circle()
                .stroke(Color.yellow.opacity(0.8), lineWidth: 3)
                .frame(width: 180, height: 180)
                .scaleEffect(pulseScale)
                .opacity(glowOpacity)
                .blur(radius: 2)
            
            // Inner glow ring
            Circle()
                .stroke(Color.orange.opacity(0.6), lineWidth: 2)
                .frame(width: 160, height: 160)
                .scaleEffect(pulseScale * 0.9)
                .opacity(glowOpacity * 0.8)
                .blur(radius: 1)
            
            // Glow effect
            Circle()
                .fill(
                    RadialGradient(
                        gradient: Gradient(colors: [
                            .yellow.opacity(0.8),
                            .orange.opacity(0.6),
                            .yellow.opacity(0.4),
                            .clear
                        ]),
                        center: .center,
                        startRadius: 20,
                        endRadius: 100
                    )
                )
                .frame(width: 200, height: 200)
                .scaleEffect(crownScale)
                .blur(radius: 15)
        }
    }
    
    // MARK: - Crown Image
    private var crownImage: some View {
        Image(systemName: "crown.fill")
            .font(.system(size: 80, weight: .bold))
            .foregroundColor(.yellow)
            .shadow(color: .yellow.opacity(0.8), radius: 10)
            .scaleEffect(crownScale)
            .rotationEffect(.degrees(crownRotation))
            .onTapGesture {
                handleCrownTap()
            }
    }
    
    // MARK: - Celebration Text Section
    private var celebrationTextSection: some View {
        Group {
            if showCongratulationsText {
                congratulationsView
            } else {
                tapInstructionsView
            }
        }
    }
    
    // MARK: - Congratulations View
    private var congratulationsView: some View {
        VStack(spacing: 16) {
            Text("🎉 LEVEL UP! 🎉")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.yellow)
                .shadow(color: .yellow.opacity(0.6), radius: 4)
            
            if let achievement = levelUpAchievement {
                VStack(spacing: 8) {
                    Text("You've reached \(achievement.levelTitle) level!")
                        .font(.headline)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                    
                    Text("\(achievement.title) • Level \(achievement.level)")
                        .font(.subheadline)
                        .foregroundColor(.orange)
                        .fontWeight(.semibold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 20)
                }
            }
            
            continueButton
        }
        .transition(.scale.combined(with: .opacity))
    }
    
    // MARK: - Continue Button
    private var continueButton: some View {
        Button("Continue Your Journey") {
            dismissLevelUpCelebration()
        }
        .font(.headline)
        .fontWeight(.bold)
        .foregroundColor(.black)
        .frame(maxWidth: .infinity)
        .padding()
        .background(
            LinearGradient(
                gradient: Gradient(colors: [.yellow, .orange]),
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(16)
        .shadow(color: .yellow.opacity(0.4), radius: 10)
        .padding(.horizontal, 20)
    }
    
    // MARK: - Tap Instructions View
    private var tapInstructionsView: some View {
        VStack(spacing: 16) {
            VStack(spacing: 8) {
                Text("Tap the crown \(3 - clickCount) more time\(3 - clickCount == 1 ? "" : "s") to celebrate!")
                    .font(.headline)
                    .foregroundColor(.yellow)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                Text("Ready to celebrate your achievement?")
                    .font(.caption)
                    .foregroundColor(.gray)
                    .fontWeight(.semibold)
                    .italic()
            }
            
            tapProgressIndicators
        }
        .opacity(crownScale > 0.8 ? 1.0 : 0.0)
        .animation(.easeInOut(duration: 0.5), value: crownScale)
    }
    
    // MARK: - Tap Progress Indicators
    private var tapProgressIndicators: some View {
        HStack(spacing: 12) {
            ForEach(0..<3, id: \.self) { index in
                Circle()
                    .fill(index < clickCount ? Color.yellow : Color.gray.opacity(0.5))
                    .frame(width: 16, height: 16)
                    .scaleEffect(index < clickCount ? 1.2 : 1.0)
                    .animation(
                        .spring(response: 0.3, dampingFraction: 0.7),
                        value: clickCount
                    )
            }
        }
        .padding(.top, 8)
    }
    
    // MARK: - Event Handlers
    private func handleLevelUpNotification(_ notification: Notification) {
        print("🔧 BadgesView: Received AchievementLevelUp notification")
        print("🎉 BadgesView received level up notification")
        if let achievement = notification.object as? Achievement {
            print("🎉 Achievement: \(achievement.title), Level: \(achievement.level)")
            showLevelUpAnimation(for: achievement)
        } else {
            print("❌ Failed to cast achievement object from notification")
            print("❌ Notification object type: \(type(of: notification.object))")
        }
    }
    
    private func handleViewAppear() {
        print("🔧 BadgesView: onAppear - AchievementManager has \(achievementManager.achievements.count) achievements")
        if let calendarAchievement = achievementManager.getCalendarAchievement() {
            print("🔧 BadgesView: Calendar achievement found - Level \(calendarAchievement.level), Progress \(calendarAchievement.currentProgress)/\(calendarAchievement.maxProgress)")
        } else {
            print("🔧 BadgesView: No calendar achievement found")
        }
    }
    
    private func handleForceLevelUp() {
        if let achievement = achievementManager.getCalendarAchievement() {
            // Force the level up by setting progress to max
            var modifiedAchievement = achievement
            modifiedAchievement.currentProgress = modifiedAchievement.maxProgress
            modifiedAchievement.level = 2
            
            // Update the achievement in the manager
            if let index = achievementManager.achievements.firstIndex(where: { $0.id == achievement.id }) {
                achievementManager.achievements[index] = modifiedAchievement
            }
            
            // Only trigger popup if we're actually leveling up
            if achievement.level == 1 && modifiedAchievement.level == 2 {
                showLevelUpAnimation(for: modifiedAchievement)
            }
            print("👑 Forced level up for testing (no notification)")
        }
    }
    
    private func handleResetAchievement() {
        if let index = achievementManager.achievements.firstIndex(where: { $0.category == .calendar }) {
            achievementManager.achievements[index].currentProgress = 0
            achievementManager.achievements[index].level = 1
            achievementManager.achievements[index].maxProgress = 3
            print("🔄 Achievement reset to level 1")
        }
    }
    
    private func handleTestCrownAnimation() {
        print("🧪 Testing crown animation directly")
        let testAchievement = Achievement(
            title: "Calendar Beginner",
            description: "Test achievement",
            icon: "calendar.badge.checkmark",
            unlockedDate: Date(),
            category: .calendar,
            level: 2,
            currentProgress: 0,
            maxProgress: 5
        )
        showLevelUpAnimation(for: testAchievement)
    }
    
    // MARK: - Animation Methods
    private func showLevelUpAnimation(for achievement: Achievement) {
        print("🎉 Starting level up celebration for: \(achievement.title) Level \(achievement.level)")
        
        // Special celebration for level 1 → 2 progression
        if achievement.level == 2 && achievement.title == "Calendar Beginner" {
            print("👑 SPECIAL: First level up! Triggering enhanced crown celebration")
        }
        
        levelUpAchievement = achievement
        showLevelUpCelebration = true
        clickCount = 0
        crownScale = 0.1
        crownRotation = 0
        showCongratulationsText = false
        overlayOpacity = 0
        glowOpacity = 0.0
        pulseScale = 1.0
        
        withAnimation(.easeInOut(duration: 0.5)) {
            overlayOpacity = 1.0
        }
        
        withAnimation(.easeOut(duration: 2.0)) {
            crownScale = 1.0
        }
        
        withAnimation(.linear(duration: 8.0).repeatForever(autoreverses: false)) {
            crownRotation = 360
        }
        
        withAnimation(.easeInOut(duration: 1.2).repeatForever(autoreverses: true)) {
            glowOpacity = 1.0
        }
        
        withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
            pulseScale = 1.4
        }
        
        // Enhanced haptic feedback for level 1 → 2
        if achievement.level == 2 {
            DispatchQueue.main.async {
                let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
                impactFeedback.impactOccurred()
                
                // Triple haptic for special level up
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    impactFeedback.impactOccurred()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
                    impactFeedback.impactOccurred()
                }
            }
        } else {
            let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
            impactFeedback.impactOccurred()
        }
    }
    
    private func handleCrownTap() {
        clickCount += 1
        print("👑 Crown tapped! Count: \(clickCount)/3")
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        withAnimation(.spring(response: 0.3, dampingFraction: 0.5)) {
            crownScale = 1.2
        }
        
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.1)) {
            crownScale = 1.0
        }
        
        if clickCount >= 3 {
            print("🎉 Three taps completed! Showing congratulations")
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                crownScale = 1.5
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                withAnimation(.easeInOut(duration: 0.8)) {
                    showCongratulationsText = true
                }
            }
        }
    }
    
    private func dismissLevelUpCelebration() {
        print("🎉 Dismissing level up celebration")
        withAnimation(.easeOut(duration: 0.8)) {
            overlayOpacity = 0
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            showLevelUpCelebration = false
            levelUpAchievement = nil
            clickCount = 0
            crownScale = 0.1
            showCongratulationsText = false
        }
    }
}

// MARK: - Achievement Badge Card
struct AchievementBadgeCard: View {
    let achievement: Achievement
    let onTap: () -> Void
    
    @State private var isPressed = false
    @State private var glowOpacity: Double = 0.3
    
    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 12) {
                badgeIconSection
                achievementInfoSection
            }
            .padding()
            .background(cardBackground)
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .buttonStyle(.plain)
        .onLongPressGesture(minimumDuration: 0.01, maximumDistance: 50) { pressing in
            isPressed = pressing
            
            if pressing {
                let impactFeedback = UIImpactFeedbackGenerator(style: .light)
                impactFeedback.impactOccurred()
            }
        } perform: {
            onTap()
        }
        .onAppear {
            startGlowAnimation()
        }
    }
    
    // MARK: - Badge Icon Section
    private var badgeIconSection: some View {
        ZStack {
            glowEffect
            mainBadgeCircle
            achievementIcon
            levelIndicator
        }
    }
    
    // MARK: - Glow Effect
    private var glowEffect: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        achievement.category.color.opacity(glowOpacity),
                        achievement.category.color.opacity(glowOpacity * 0.5),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 10,
                    endRadius: 40
                )
            )
            .frame(width: 80, height: 80)
            .blur(radius: 4)
    }
    
    // MARK: - Main Badge Circle
    private var mainBadgeCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        achievement.category.color,
                        achievement.category.color.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 60, height: 60)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 2)
            )
            .shadow(color: achievement.category.color.opacity(0.5), radius: 4)
    }
    
    // MARK: - Achievement Icon
    private var achievementIcon: some View {
        Image(systemName: achievement.icon)
            .font(.system(size: 24, weight: .bold))
            .foregroundColor(.white)
    }
    
    // MARK: - Level Indicator
    private var levelIndicator: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Text("\(achievement.level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(4)
                    .background(Circle().fill(Color.black.opacity(0.7)))
                    .offset(x: 8, y: 8)
            }
        }
    }
    
    // MARK: - Achievement Info Section
    private var achievementInfoSection: some View {
        VStack(spacing: 4) {
            Text(achievement.title)
                .font(.headline)
                .fontWeight(.bold)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
                .lineLimit(1)
            
            Text(achievement.levelTitle)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(achievement.category.color)
            
            // Progress bar
            ProgressView(value: achievement.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                .scaleEffect(x: 1, y: 0.5)
            
            Text("\(achievement.currentProgress)/\(achievement.maxProgress)")
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
    
    // MARK: - Card Background
    private var cardBackground: some View {
        RoundedRectangle(cornerRadius: 16)
            .fill(Color(.systemBackground))
            .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
    }
    
    private func startGlowAnimation() {
        withAnimation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true)) {
            glowOpacity = 0.6
        }
    }
}

// MARK: - Achievement Detail View
struct AchievementDetailView: View {
    let achievement: Achievement
    let achievementManager: AchievementManager
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 30) {
                    Spacer().frame(height: 20)
                    largeBadgeDisplay
                    achievementInfoSection
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Achievement")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Large Badge Display
    private var largeBadgeDisplay: some View {
        ZStack {
            largeBadgeGlow
            largeBadgeCircle
            largeBadgeIcon
            largeBadgeLevelIndicator
        }
    }
    
    // MARK: - Large Badge Components
    private var largeBadgeGlow: some View {
        Circle()
            .fill(
                RadialGradient(
                    gradient: Gradient(colors: [
                        achievement.category.color.opacity(0.6),
                        achievement.category.color.opacity(0.3),
                        .clear
                    ]),
                    center: .center,
                    startRadius: 20,
                    endRadius: 80
                )
            )
            .frame(width: 160, height: 160)
            .blur(radius: 8)
    }
    
    private var largeBadgeCircle: some View {
        Circle()
            .fill(
                LinearGradient(
                    gradient: Gradient(colors: [
                        achievement.category.color,
                        achievement.category.color.opacity(0.8)
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .frame(width: 120, height: 120)
            .overlay(
                Circle()
                    .stroke(Color.white, lineWidth: 3)
            )
            .shadow(color: achievement.category.color.opacity(0.5), radius: 8)
    }
    
    private var largeBadgeIcon: some View {
        Image(systemName: achievement.icon)
            .font(.system(size: 48, weight: .bold))
            .foregroundColor(.white)
    }
    
    private var largeBadgeLevelIndicator: some View {
        VStack {
            HStack {
                Spacer()
                Text("LVL \(achievement.level)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Capsule().fill(Color.black.opacity(0.8)))
            }
            Spacer()
        }
        .padding(8)
    }
    
    // MARK: - Achievement Info Section
    private var achievementInfoSection: some View {
        VStack(spacing: 16) {
            basicInfoSection
            progressSection
            unlockedDateSection
        }
    }
    
    // MARK: - Basic Info Section
    private var basicInfoSection: some View {
        VStack(spacing: 8) {
            Text(achievement.title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(.primary)
            
            Text(achievement.levelTitle)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundColor(achievement.category.color)
            
            Text(achievement.description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
        }
    }
    
    // MARK: - Progress Section
    private var progressSection: some View {
        VStack(spacing: 12) {
            Text("Progress to Next Level")
                .font(.headline)
                .fontWeight(.semibold)
            
            progressBar
            
            nextLevelDescription
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.1), radius: 4)
        .padding(.horizontal)
    }
    
    // MARK: - Progress Bar
    private var progressBar: some View {
        VStack(spacing: 8) {
            HStack {
                Text("\(achievement.currentProgress)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.category.color)
                
                Spacer()
                
                Text("\(achievement.maxProgress)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
            }
            
            ProgressView(value: achievement.progressPercentage)
                .progressViewStyle(LinearProgressViewStyle(tint: achievement.category.color))
                .scaleEffect(x: 1, y: 2)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    // MARK: - Next Level Description
    private var nextLevelDescription: some View {
        Group {
            if achievement.level < 6 {
                Text("Continue using the calendar to progress!")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            } else {
                Text("🎉 Max Level Achieved!")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(achievement.category.color)
            }
        }
    }
    
    // MARK: - Unlocked Date Section
    private var unlockedDateSection: some View {
        VStack(spacing: 4) {
            Text("Unlocked")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.secondary)
            
            if let unlockedDate = achievement.unlockedDate {
                Text(unlockedDate, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
            } else {
                Text("Not yet unlocked")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
    }
}

// MARK: - Preview
struct BadgesView_Previews: PreviewProvider {
    static var previews: some View {
        BadgesView().environmentObject(AchievementManager())
    }
}