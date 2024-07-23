import SwiftUI

class AccountViewModel: ObservableObject {
    @AppStorage("zNotSelected") var zNotSelected = false
    @Published var yUsSelected = false
    @Published var bIncogSelected = false
    @Published var cDeleteSelected = false
    @Published var showingSheet = false
}
