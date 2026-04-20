import SwiftUI

struct NFCControlsView: View {
    @Binding var brand: String
    @Binding var filament: String
    @Binding var variantText: String
    @Binding var hexColor: String
    @Binding var customColors: [String]
    @Binding var minTemp: String
    @Binding var maxTemp: String
    @Binding var bedMinTemp: String
    @Binding var bedMaxTemp: String
    @Binding var gewicht: String
    @Binding var gewichtSpoel: String
    @Binding var dichtheid: String
    @Binding var prijs: String
    @Binding var currency: String
    @Binding var partijNr: String
    @Binding var diameter: String

    @ObservedObject var reader: SpoolNFCViewModel
    let onRequestWrite: () -> Void
    let onWriterClearAndReset: () -> Void
    let onReaderAndReset: () -> Void
        
    fileprivate func intFromString(_ s: String) -> Int? {
        Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }

    fileprivate func doubleFromString(_ s: String) -> Double? {
        Double(s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."))
    }
    
    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 8) {
                Button(action: {
                // vul pendingOpenSpool vanuit UI-state
                self.reader.pendingOpenSpool = OpenSpool(
                id: nil,
                protocolName: "openspool",
                version: "1.0",
                brand: self.brand.isEmpty ? "Algemeen" : self.brand,
                type: self.filament,
                subtype: self.variantText,
                color_hex: self.hexColor.replacingOccurrences(of: "#", with: ""),
                additional_color_hexes: self.customColors.isEmpty ? [] : self.customColors,
                alpha: "FF",
                min_temp: intFromString(self.minTemp) ?? 0,
                max_temp: intFromString(self.maxTemp) ?? 0,
                bed_min_temp: intFromString(self.bedMinTemp) ?? 0,
                bed_max_temp: intFromString(self.bedMaxTemp) ?? 0,
                weight: doubleFromString(self.gewicht) ?? 0.0,
                spoolweight: doubleFromString(self.gewichtSpoel) ?? 0.0,
                density: doubleFromString(self.dichtheid) ?? 0.0,
                price: doubleFromString(self.prijs) ?? 0.0,
                currency: self.currency,
                lot_nr: self.partijNr,
                diameter: doubleFromString(self.diameter) ?? 0.0
                )


                UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)

                // start writer on next runloop to ensure bindings applied
                DispatchQueue.main.async {
                    self.onRequestWrite()
                }
                }) { 
                    Text(NSLocalizedString("writing.button", comment: "Writing button"))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.sRGB, red: 0.07, green: 0.07, blue: 0.07))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .cornerRadius(16)
                }

                Button(action: { reader.startWriter(mode: .clear) }) {
                    Text(NSLocalizedString("clear.button", comment: "Clear button"))
                        .fontWeight(.semibold)
                        .foregroundColor(Color(.sRGB, red: 0.07, green: 0.07, blue: 0.07))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 14)
                        .background(Color.yellow)
                        .cornerRadius(16)
                }
            }

            Button(action: { reader.startReader() }) {
                Text(NSLocalizedString("reading.button", comment: "Read button"))
                    .fontWeight(.semibold)
                    .foregroundColor(Color(.sRGB, red: 0.07, green: 0.07, blue: 0.07))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .padding(.horizontal, -7)
                    .background(Color.yellow)
                    .cornerRadius(16)
            }

           

            // Bullet-list left aligned
            VStack(alignment: .leading, spacing: 6) {
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.primary)
                    Text(NSLocalizedString("config.text", comment: "Config settings"))
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.primary)
                    Text(NSLocalizedString("writing.text", comment: "Writing instructions"))
                }
                HStack(alignment: .top, spacing: 8) {
                    Text("•").foregroundColor(.primary)
                    Text(NSLocalizedString("reading.text", comment: "Reading instructions"))
                }
            }
            .font(.footnote)
            .foregroundColor(.primary)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.top, 6)
            
        }
        .padding(.top, 2)
        .padding(.horizontal, -18)
    }
}
