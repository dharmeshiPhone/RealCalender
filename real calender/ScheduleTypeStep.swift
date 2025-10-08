import SwiftUI

struct ScheduleTypeStep: View {
    @Binding var selectedScheduleType: ScheduleType

    var body: some View {
        VStack(spacing: 30) {
            VStack(spacing: 16) {
                Text("What's your main schedule?")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("I'll create a template based on your situation")
                    .font(.body)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            VStack(spacing: 16) {
                ForEach(ScheduleType.allCases, id: \.self) { scheduleType in
                    Button(action: {
                        selectedScheduleType = scheduleType
                    }) {
                        HStack(spacing: 16) {
                            Image(systemName: scheduleType.icon)
                                .font(.title2)
                                .foregroundColor(scheduleType.color)
                                .frame(width: 40)

                            VStack(alignment: .leading, spacing: 4) {
                                Text(scheduleType.rawValue)
                                    .font(.headline)
                                    .fontWeight(.semibold)

                                Text(getScheduleDescription(scheduleType))
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }

                            Spacer()

                            if selectedScheduleType == scheduleType {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                    .font(.title2)
                            } else {
                                Image(systemName: "circle")
                                    .foregroundColor(.gray)
                                    .font(.title2)
                            }
                        }
                        .padding()
                        .background(
                            selectedScheduleType == scheduleType ?
                            scheduleType.color.opacity(0.1) :
                            Color(.systemGray6)
                        )
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(
                                    selectedScheduleType == scheduleType ?
                                    scheduleType.color :
                                    Color.clear,
                                    lineWidth: 2
                                )
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }

    private func getScheduleDescription(_ scheduleType: ScheduleType) -> String {
        switch scheduleType {
        case .highSchool:
            return "Classes, study periods, and extracurriculars"
        case .university:
            return "Lectures, seminars, and study time"
        case .work:
            return "Work hours, meetings, and breaks"
        }
    }
}