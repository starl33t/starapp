import SwiftUI
import SwiftData

struct AccountView: View {
    @State private var deleteOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    @State private var startPositionPercentage: CGFloat = 0.025
    @State private var deleteUser = false
    @AppStorage("Pace") var paceToggle: Bool = true
    @AppStorage("Power") var powerToggle: Bool = true
    @AppStorage("Heartrate") var heartRateToggle: Bool = true
    @AppStorage("Distance") var distanceToggle: Bool = true
    @AppStorage("Duration") var durationToggle: Bool = true
    @AppStorage("Research") var researchToggle: Bool = false
    @FocusState private var textCalibrationFieldIsFocused: Bool
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var allSessions: [Session]
    
    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                VStack {
                    HStack {
                        Toggle("Duration", isOn: $durationToggle)
                    }
                    .padding()
                  
                    HStack {
                        Toggle("Distance", isOn: $distanceToggle)
                    }
                    .padding()
                    
                    HStack {
                        Toggle("Heartrate", isOn: $heartRateToggle)
                    }
                    .padding()
                    
                    HStack {
                        Toggle("Pace", isOn: $paceToggle)
                    }
                    .padding()
                    
                    HStack {
                        Toggle("Power", isOn: $powerToggle)
                    }
                    .padding()
                   
                    HStack {
                        Toggle("Research Mode", isOn: $researchToggle)
                    }
                    .padding()
                    
                }
                .padding()
                .background(Color.starBlack)
                .cornerRadius(16)
                
                GeometryReader { geometry in
                    let width = geometry.size.width
                    let sliderWidth = width - 40
                    let ballDiameter: CGFloat = 50
                    let maxOffsetPercentage: CGFloat = 0.86
                    let maxOffset = (sliderWidth - ballDiameter) * maxOffsetPercentage
                    let initialOffset = (sliderWidth - ballDiameter) * startPositionPercentage
                    
                    VStack {
                        ZStack(alignment: .leading) {
                            Capsule()
                                .fill(Color.red.opacity(0.2 + (deleteOffset / maxOffset) * 0.9))
                                .frame(height: 60)
                            
                            Text("Slide to delete all data")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 20)
                            
                            Circle()
                                .fill(Color.white)
                                .frame(width: ballDiameter, height: ballDiameter)
                                .offset(x: min(max(initialOffset, deleteOffset), maxOffset))
                                .gesture(
                                    DragGesture()
                                        .onChanged { value in
                                            let newOffset = min(max(initialOffset, initialOffset + value.translation.width), maxOffset)
                                            deleteOffset = newOffset
                                        }
                                        .onEnded { value in
                                            if deleteOffset > maxOffset * 0.95 {
                                                withAnimation {
                                                    deleteUser = true
                                                    deleteOffset = maxOffset
                                                    showDeleteAlert = true
                                                }
                                            } else {
                                                withAnimation {
                                                    deleteOffset = initialOffset
                                                }
                                            }
                                        }
                                )
                        }
                        .frame(height: 60)
                        .padding(.horizontal, 20)
                    }
                    .padding()
                    .background(Color.starBlack)
                    .cornerRadius(16)
                }
                .frame(height: 100)
            }
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .alert(isPresented: $showDeleteAlert) {
                Alert(
                    title: Text("Delete All Data"),
                    message: Text("Are you sure you want to delete all data? This action cannot be undone."),
                    primaryButton: .destructive(Text("Delete")) {
                        performUserReset()
                    },
                    secondaryButton: .cancel {
                        withAnimation {
                            deleteOffset = 0
                        }
                    }
                )
            }
        }
        .onTapGesture {
            textCalibrationFieldIsFocused = false
        }
    }
    
    private func performUserReset() {
        // Delete all sessions
        for session in allSessions {
            modelContext.delete(session)
        }
        do {
            paceToggle = true
            powerToggle = true
            heartRateToggle = true
            distanceToggle = true
            durationToggle = true
            researchToggle = false
            try modelContext.save()
            
            dismiss()
        } catch {
            print("Failed to reset user data and sessions: \(error.localizedDescription)")
        }
    }
}
