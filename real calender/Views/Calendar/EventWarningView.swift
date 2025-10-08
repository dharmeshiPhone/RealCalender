import SwiftUI

struct EventWarningView: View {
    let currentEventCount: Int
    @Binding var isPresented: Bool
    let onRetakePhoto: () -> Void
    let onAddMorePhotos: () -> Void
    let onProceedAnyway: () -> Void
    
    private var eventsNeeded: Int {
        max(0, 7 - currentEventCount)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                VStack(spacing: 16) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .font(.system(size: 60))
                        .foregroundColor(.orange)
                    
                    Text("Need More Events")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                    
                    Text("Add more photos to capture your complete schedule")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                
                VStack(spacing: 16) {
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("Current Events")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(currentEventCount)")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(currentEventCount >= 7 ? .green : .orange)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "plus")
                            .font(.title)
                            .foregroundColor(.blue)
                        
                        Spacer()
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            Text("Add More")
                                .font(.caption)
                                .foregroundColor(.secondary)
                            
                            Text("\(eventsNeeded)+")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    if eventsNeeded > 0 {
                        Text("Your existing \(currentEventCount) events will be kept!")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                }
                
                VStack(spacing: 20) {
                    Text("Choose how to add more events:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    VStack(spacing: 16) {
                        Button(action: onAddMorePhotos) {
                            HStack(spacing: 12) {
                                Image(systemName: "plus.rectangle.on.rectangle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Add More Photos")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Keep current \(currentEventCount) events + add new ones")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                        }
                        
                        Button(action: onRetakePhoto) {
                            HStack(spacing: 12) {
                                Image(systemName: "arrow.clockwise.circle")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Replace All Photos")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("Start over with different timetable images")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.orange)
                            .cornerRadius(12)
                        }
                        
                        HStack {
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                            
                            Text("OR")
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .padding(.horizontal, 8)
                            
                            Rectangle()
                                .fill(Color(.systemGray4))
                                .frame(height: 1)
                        }
                        .padding(.vertical, 8)
                        
                        Button(action: onProceedAnyway) {
                            HStack(spacing: 12) {
                                Image(systemName: "checkmark.circle.fill")
                                    .font(.title2)
                                    .foregroundColor(.white)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text("Continue with \(currentEventCount) Events")
                                        .font(.headline)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.white)
                                    
                                    Text("You can add more events later manually")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding()
                            .background(Color.green)
                            .cornerRadius(12)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .leading, spacing: 8) {
                    Text("💡 Pro Tip:")
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                    
                    Text("Adding more photos is non-destructive - your existing \(currentEventCount) events will be preserved and new ones will be added to your schedule!")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
            }
            .padding()
            .navigationTitle("Add More Events")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        isPresented = false
                    }
                }
            }
        }
    }
}