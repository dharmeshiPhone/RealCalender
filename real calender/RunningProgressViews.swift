import SwiftUI
import Charts

// MARK: - Run Record Row
struct RunRecordRow: View {
    let run: RunRecord
    let isLatest: Bool
    
    var body: some View {
        HStack(spacing: 12) {
            // Date and time
            VStack(alignment: .leading, spacing: 2) {
                Text(run.date, style: .date)
                    .font(.caption)
                    .foregroundColor(.secondary)
                
                Text(run.timeFormatted)
                    .font(.headline)
                    .fontWeight(run.isPersonalBest ? .bold : .semibold)
                    .foregroundColor(run.isPersonalBest ? .green : .primary)
            }
            
            // Personal best indicator
            if run.isPersonalBest {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
            
            Spacer()
            
            // Improvement indicator
            VStack(alignment: .trailing, spacing: 2) {
                Text(run.improvementText)
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(run.improvementColor)
                
                Text(run.paceFormatted)
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .background(
            RoundedRectangle(cornerRadius: 8)
                .fill(isLatest ? Color.green.opacity(0.1) : Color(.systemGray6))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(
                            isLatest ? Color.green.opacity(0.3) : Color.clear,
                            lineWidth: 1
                        )
                )
        )
    }
}

// MARK: - Running Progress Graph
struct RunningProgressGraph: View {
    let runs: [RunRecord]
    
    private var chartData: [(date: Date, time: Double, isPB: Bool)] {
        return runs.reversed().map { run in // Reverse to show chronologically
            (date: run.date, time: Double(run.timeSec) / 60.0, isPB: run.isPersonalBest)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            chartView
            legendView
        }
        .padding(12)
        .background(backgroundView)
    }
    
    private var headerView: some View {
        HStack {
            Text("Progress Over Time")
                .font(.subheadline)
                .fontWeight(.semibold)
            
            Spacer()
            
            Text("📈 Unlocked!")
                .font(.caption2)
                .fontWeight(.bold)
                .foregroundColor(.green)
        }
    }
    
    private var chartView: some View {
        Chart {
            ForEach(chartData, id: \.date) { dataPoint in
                LineMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Time", dataPoint.time)
                )
                .foregroundStyle(.green)
                .lineStyle(StrokeStyle(lineWidth: 2))
                
                PointMark(
                    x: .value("Date", dataPoint.date),
                    y: .value("Time", dataPoint.time)
                )
                .foregroundStyle(dataPoint.isPB ? .yellow : .green)
                .symbolSize(dataPoint.isPB ? 100 : 60)
            }
        }
        .chartYAxis {
            AxisMarks(position: .leading) { _ in
                AxisGridLine()
                AxisValueLabel()
            }
        }
        .chartXAxis {
            AxisMarks(position: .bottom) { _ in
                AxisGridLine()
                AxisValueLabel(format: .dateTime.month(.abbreviated).day())
            }
        }
        .frame(height: 120)
    }
    
    private var legendView: some View {
        HStack(spacing: 16) {
            HStack(spacing: 4) {
                Circle()
                    .fill(.green)
                    .frame(width: 8, height: 8)
                Text("Run")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            HStack(spacing: 4) {
                Diamond()
                    .fill(.yellow)
                    .frame(width: 8, height: 8)
                Text("Personal Best")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            let bestTime = runs.min(by: { $0.timeSec < $1.timeSec })?.timeFormatted ?? "N/A"
            Text("Best: \(bestTime)")
                .font(.caption2)
                .fontWeight(.semibold)
                .foregroundColor(.green)
        }
    }
    
    private var backgroundView: some View {
        RoundedRectangle(cornerRadius: 8)
            .fill(Color.green.opacity(0.05))
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(Color.green.opacity(0.2), lineWidth: 1)
            )
    }
}

// MARK: - Diamond Shape for PB markers
struct Diamond: Shape {
    func path(in rect: CGRect) -> Path {
        Path { path in
            let center = CGPoint(x: rect.midX, y: rect.midY)
            let radius = min(rect.width, rect.height) / 2
            
            path.move(to: CGPoint(x: center.x, y: center.y - radius))
            path.addLine(to: CGPoint(x: center.x + radius, y: center.y))
            path.addLine(to: CGPoint(x: center.x, y: center.y + radius))
            path.addLine(to: CGPoint(x: center.x - radius, y: center.y))
            path.closeSubpath()
        }
    }
}

#Preview {
    VStack {
        let sampleRuns = [
            RunRecord(
                date: Date().addingTimeInterval(-60*60*24*7), // 7 days ago
                timeSec: 1500, // 25:00
                distance: 5000,
                averagePace: 300,
                isPersonalBest: false,
                improvementFromPrevious: nil
            ),
            RunRecord(
                date: Date().addingTimeInterval(-60*60*24*4), // 4 days ago
                timeSec: 1440, // 24:00
                distance: 5000,
                averagePace: 288,
                isPersonalBest: true,
                improvementFromPrevious: -60
            ),
            RunRecord(
                date: Date().addingTimeInterval(-60*60*24*1), // 1 day ago
                timeSec: 1470, // 24:30
                distance: 5000,
                averagePace: 294,
                isPersonalBest: false,
                improvementFromPrevious: 30
            ),
            RunRecord(
                date: Date(), // Today
                timeSec: 1410, // 23:30
                distance: 5000,
                averagePace: 282,
                isPersonalBest: true,
                improvementFromPrevious: -60
            )
        ]
        
        RunningProgressGraph(runs: sampleRuns)
            .padding()
        
        VStack {
            ForEach(Array(sampleRuns.enumerated()), id: \.element.id) { index, run in
                RunRecordRow(run: run, isLatest: index == sampleRuns.count - 1)
            }
        }
        .padding()
    }
}