import SwiftUI
import SwiftData

struct HomeView: View {
    @EnvironmentObject var appState: AppState
    @EnvironmentObject var viewModel: MessageHelper
    @Environment(\.modelContext) private var context
    @AppStorage("isprofileSelected") private var isprofileSelected = false
    @AppStorage("isChatSelected") private var isChatSelected = false
    @AppStorage("Adc") private var adc: Int = 0
    @AppStorage("Current") private var current: Double = 0.0
    @AppStorage("Lactate") private var lactate: Double = 0.0
    @AppStorage("uidString") private var uidString: String = ""
    
    var body: some View {
        VStack {
            scanGuide()
            Text("Lactate: \(lactate, specifier: "%.1f") mM")
                .font(.system(size: 42, weight: .bold))
                .foregroundColor(.whiteOne)
                .padding(.top, 106)
            
            Text(LactateHelper.intensity(for: lactate).rawValue)
                .font(.system(size: 28, weight: .bold))
                .foregroundColor(.darkTwo)
            Spacer()
        }
        .onChange(of: uidString) {
            createNewTrainingSession()
        }
        .onAppear{
            isChatSelected = false
        }
        if isprofileSelected {
            VStack {
                ZStack(alignment: .top) {
                    Color.starBlack.opacity(0.98).ignoresSafeArea()
                        .frame(height: 305)
                }
                Spacer()
            }
            .transition(.move(edge: .top))
            .animation(.easeInOut(duration: 0.3), value: isprofileSelected)
            .onTapGesture {
                isprofileSelected = false
            }
        }
    }
    
    //New training session whenever a new lactate values
    private func createNewTrainingSession() {
        let newSession = Session(
            lactate: lactate,
            date: Date(),
            uidString: uidString,
            adc: adc,
            current: current
        )
        context.insert(newSession)
    }
    
    @ViewBuilder
    private func scanGuide() -> some View {
        HStack {
          Text("↑Scan here↑")
                .foregroundStyle(.whiteOne)
                
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(AppState())
}


