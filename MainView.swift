import SwiftUI
import Combine

struct MainView: View {
    @AppStorage("spoolman_ip") private var spoolmanIP: String = ""
    @State private var filaments: [Filament] = []
    @State private var selectedFilamentID: Int?
    @State private var loading = false
    @State private var errorMessage: String?
    @State private var cancellable: AnyCancellable?

    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                if spoolmanIP.isEmpty {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.title2)
                            .foregroundColor(.yellow)
                        Text(NSLocalizedString("spoolman.title", comment: "greetings if spoolman is not loaded"))
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding()
                } else {
                    if loading {
                        ProgressView(NSLocalizedString("spoolman.loading", comment: "Loading spoolman"))
                            .padding()
                    } else if let error = errorMessage {
                        Text("Fout: \(error)")
                            .foregroundColor(.red)
                            .padding()
                    } else {
                        if filaments.isEmpty {
                            Text("Geen filamenten gevonden")
                                .padding()
                        } else {
                            Picker("Filament", selection: $selectedFilamentID) {
                                ForEach(filaments) { f in
                                    Text(f.name).tag(f.id as Int?)
                                }
                            }
                            .pickerStyle(MenuPickerStyle()) // dropdown-achtig
                            .padding()
                        }
                    }
                }

                Spacer()
            }
        }
    }
}
