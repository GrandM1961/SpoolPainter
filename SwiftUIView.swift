import SwiftUI

struct FilamentView: View {
    @Environment(\.dismiss) private var dismiss
    
    @State private var naam = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text(NSLocalizedString("filamentview.newfilament", comment: "New filament"))
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextField(NSLocalizedString("filamentview.name.filament", comment: "Name of filament"), text: $naam)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal)
                
                Button(NSLocalizedString("filamentview.add.filament", comment: "Add new filament")) {
                    // Hier sla je op (je lijst)
                    dismiss()  // ← TERUG!
                }
                .buttonStyle(.borderedProminent)
                .disabled(naam.isEmpty)  // ← Slim!
            }
            .padding()
            .navigationTitle("Filament")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
