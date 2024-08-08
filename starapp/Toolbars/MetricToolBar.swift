import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct MetricToolBar: View {
    @Query private var sessions: [Session]
    @AppStorage("showAnnotations") var showAnnotations = true
    @State private var isExporting = false
    
    var body: some View {
        HStack {
            Button(action: {
                showAnnotations.toggle()
            }) {
                Label("Values", systemImage: showAnnotations ? "tag" : "tag.slash")
            }
            Button(action: {
                isExporting = true
            }) {
                Label("CSV Export", systemImage: "list.bullet.clipboard")
            }
        }
        .fileExporter(
            isPresented: $isExporting,
            document: CSVDocument(sessions: sessions),
            contentType: .commaSeparatedText,
            defaultFilename: "sessions.csv"
        ) { result in
            switch result {
            case .success(let url):
                print("Saved to \(url)")
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

#Preview {
    MetricToolBar()
}
