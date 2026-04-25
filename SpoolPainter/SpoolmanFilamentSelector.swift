import SwiftUI
import Combine

 struct SpoolmanFilamentSelector: View {
     @Binding var spoolmanIP: String
     @Binding var selectedFilamentID: Int?
     @Binding var isSelectedVisual: Bool
     var disableAutoApply: Bool = false  // ← BEFORE onApply
     var onApply: (Filament) -> Void

     @State private var filaments: [Filament] = []
     @State private var loading = false
     @State private var errorMessage: String?
     @State private var cancellable: AnyCancellable?
     

     var body: some View {
         Group {
             if spoolmanIP.isEmpty {
                 HStack(alignment: .center, spacing: 12) {
                     Image(systemName: "lightbulb")
                         .font(.title2)
                         .foregroundColor(.yellow)
                         .padding(.leading, 8)
                     Text(NSLocalizedString("spoolman.connect.tooltip", comment: "Tooltip voor Spoolman"))
                         .font(.caption)
                         .foregroundColor(.white)
                         .lineLimit(2)
                         .fixedSize(horizontal: false, vertical: true)
                         .padding(.vertical, 12)
                     Spacer()
                 }
                 .padding(.horizontal, 4)
                 .background(Color.white.opacity(0.15))
                 .cornerRadius(12)
                 .padding(.horizontal)
             } else if loading {
                 HStack { ProgressView(); Text(NSLocalizedString("spoolman.loading", comment: "Loading of Spoolman Server")) }.padding()
             } else if let err = errorMessage {
                 Text("Fout: \(err)").foregroundColor(.red).padding()
             } else {
                 VStack(spacing: 16) {
                     Menu {
                     ForEach(filaments) { f in
                         Button(f.name) {
                             selectedFilamentID = f.id
                             isSelectedVisual = true
                             onApply(f)
                         }
                     }
                     } label: {
                         let cornerRadius: CGFloat = 12
                         let fieldHeight: CGFloat = 48
                         let badgePadH: CGFloat = 8
                         let badgePadV: CGFloat = 4
                         ZStack(alignment: .topLeading) {
                             Text("Spoolman filament")
                                 .font(.caption).bold()
                                 .foregroundColor(isSelectedVisual ? Color.black : Color.white)
                                 .padding(.horizontal, badgePadH)
                                 .padding(.vertical, badgePadV)
                                 .background(isSelectedVisual ? Color.yellow : Color.black)
                                 .cornerRadius(6)
                                 .fixedSize()
                                 .offset(x: 16, y: -((fieldHeight / 2) - badgePadV - 2))
                                 .zIndex(2)

                             HStack {
                                 Text(selectedFilamentID == nil ? NSLocalizedString("choose.spoolman.filament", comment: "Choosing a filament")
                                 : (filaments.first(where: { $0.id == selectedFilamentID })?.name ?? NSLocalizedString("selected.spoolman.filament", comment: "Selected filament")))
                                     .font(.body.bold())
                                     .foregroundColor(.white)
                                     .lineLimit(1)
                                 Spacer()
                                 Image(systemName: "chevron.down").foregroundColor(.white.opacity(0.8))
                             }
                             .padding(.horizontal, 20)
                             .padding(.vertical, (fieldHeight - 16) / 2)
                             .frame(height: fieldHeight)
                             .frame(maxWidth: .infinity)
                             .background(Color.gray.opacity(0.4))
                             .overlay(RoundedRectangle(cornerRadius: cornerRadius).stroke(isSelectedVisual ? Color.yellow : Color.gray, lineWidth: 3))
                         }
                         .frame(height: fieldHeight)
                         .frame(maxWidth: .infinity) // allow full width
                     }
                     .buttonStyle(.plain)
                     .onChange(of: selectedFilamentID) { _, _ in
                         withAnimation(.none) { isSelectedVisual = (selectedFilamentID != nil) }
                     }
                     }
                     .frame(maxWidth: .infinity)
                     .padding(.horizontal, -16)
                     .padding(.top, 16)
             }
         }
         .onAppear { loadIfNeeded() }
         .onChange(of: spoolmanIP) { _, _ in loadIfNeeded() }
     }
     private func selectFilament(_ f: Filament) {
             selectedFilamentID = f.id
             isSelectedVisual = true
             if !disableAutoApply {  // ← ONLY apply if not disabled
                 onApply(f)
             }
         }

     private func loadIfNeeded() {
         errorMessage = nil
         filaments = []

         let currentSelection = selectedFilamentID

         let ip = spoolmanIP.trimmingCharacters(in: .whitespacesAndNewlines)
         guard !ip.isEmpty else { return }

         loading = true
         cancellable?.cancel()
         cancellable = SpoolmanClient.shared.fetchFilaments(urlString: ip)
             .receive(on: DispatchQueue.main)
             .sink(receiveCompletion: { completion in
                 loading = false
                 if case let .failure(err) = completion {
                     errorMessage = err.localizedDescription
                 }
             }, receiveValue: { list in
                 filaments = list
                 if let keep = currentSelection, list.contains(where: { $0.id == keep }) {
                     selectedFilamentID = keep
                     isSelectedVisual = true
                 }
             }
        )
             
     }
 }
