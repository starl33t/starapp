import SwiftUI

struct AccountView: View {
    @StateObject private var viewModel = AccountViewModel()
    @State private var deleteOffset: CGFloat = 0
    @State private var showDeleteAlert = false
    private let maxOffset: CGFloat = 238 // Maximum offset for the slider

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
            ToggleView(title: "US units", isOn: $viewModel.yUsSelected)
            ToggleView(title: "Notifications", isOn: $viewModel.zNotSelected)
            ToggleView(title: "Incognito mode", isOn: $viewModel.bIncogSelected)
        }
        .padding()
        .background(Color.starBlack)
        .cornerRadius(16)
    }

    private var deleteSlider: some View {
        VStack {
            ZStack(alignment: .leading) {
                Capsule()
                    .fill(capsuleColor(for: deleteOffset))
                    .frame(height: 60)

                Text("Slide to delete account")
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)

                Circle()
                    .fill(Color.white)
                    .frame(width: 50, height: 50)
                    .offset(x: deleteOffset)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if value.translation.width >= 0 && value.translation.width <= maxOffset {
                                    deleteOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                if deleteOffset > maxOffset - 10 { // Adjust threshold for triggering the alert
                                    withAnimation {
                                        viewModel.cDeleteSelected = true
                                        deleteOffset = maxOffset // Snap to the end
                                        showDeleteAlert = true
                                    }
                                } else {
                                    withAnimation {
                                        deleteOffset = 0
                                    }
                                }
                            }
                    )
                    .padding(5)
            }
            .padding(.horizontal)
        }
        .padding()
        .background(Color.starBlack)
        .cornerRadius(16)
    }

    private var deleteAlert: Alert {
        Alert(
            title: Text("Delete Account"),
            message: Text("Are you sure you want to delete your account? This action cannot be undone."),
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

    private func capsuleColor(for offset: CGFloat) -> Color {
        let progress = offset / maxOffset
        return Color.red.opacity(0.1 + progress * 0.9) // Start at 10% opacity and move to 100% opacity
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
