import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @State private var deleteOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    @State private var startPositionPercentage: CGFloat = 0.025 // 0.0 means far left, 1.0 means far right

    var body: some View {
        ZStack {
            Color.starBlack.ignoresSafeArea()
            VStack {
                settingsToggles
                deleteSlider
            }
            .padding()
            .background(Color.starBlack)
            .cornerRadius(16)
            .presentationDetents([.medium])
            .onAppear {
                viewModel.showingSheet = true
            }
            .alert(isPresented: $showDeleteAlert) {
                deleteAlert
            }
        }
    }

    private var settingsToggles: some View {
        VStack {
            ToggleView(title: "Notifications", isOn: $viewModel.zNotSelected)
                .tint(.green)
        }
        .padding()
        .background(Color.starBlack)
        .cornerRadius(16)
    }

    private var deleteSlider: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let sliderWidth = width - 40 // Adjust for padding
            let ballDiameter: CGFloat = 50
            let maxOffsetPercentage: CGFloat = 0.86 // 85% of the slider width
            let maxOffset = (sliderWidth - ballDiameter) * maxOffsetPercentage

            // Calculate the initial offset based on the start position percentage
            let initialOffset = (sliderWidth - ballDiameter) * startPositionPercentage

            VStack {
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(capsuleColor(for: deleteOffset, maxOffset: maxOffset))
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
                                            viewModel.cDeleteSelected = true
                                            deleteOffset = maxOffset // Snap to the end
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
        .frame(height: 100) // Fixed height for the slider
    }
    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete All Data"),
            message: Text("Are you sure you want to delete all data? This action cannot be undone."),
            primaryButton: .destructive(Text("Delete")) {
                // Handle delete action
            },
            secondaryButton: .cancel {
                withAnimation {
                    deleteOffset = 0 // Reset the ball position when canceling
                }
            }
        )
    }

    private func capsuleColor(for offset: CGFloat, maxOffset: CGFloat) -> Color {
        let progress = offset / maxOffset
        return Color.red.opacity(0.2 + progress * 0.9) // Start at 10% opacity and move to 100% opacity
    }
}

struct ToggleView: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Toggle(title, isOn: $isOn)
        }
        .padding()
        .foregroundColor(.whiteOne)
    }
}

#Preview {
    AccountView()
}
