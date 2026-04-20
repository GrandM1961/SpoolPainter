import SwiftUI

struct PriceField: View {
    @Binding var price: String
    @Binding var currency: String
    @Binding var edited: Bool

    @State private var showingInfoAlert = false
    

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                HStack {
                    TextField("", text: $price)
                        .keyboardType(.decimalPad)
                        .padding(.leading, 12)
                        .padding(.vertical, 12)

                    Text(currency.isEmpty ? "€" : currency)
                        .font(.body)
                        .padding(.trailing, 8)
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(edited ? Color.yellow : Color.gray, lineWidth: 2)
                )
                .onChange(of: price) {_, newValue in
                    let normalized = newValue.replacingOccurrences(of: "\n", with: "")
                                              .replacingOccurrences(of: ",", with: ".")
                    price = normalized
                    // now price uses dot and can be stored directly
                    if !edited { edited = true }
                }
                .simplePlaceholder("0.00", when: price.isEmpty)
                
                Text(NSLocalizedString("PriceField.Title", comment: "Price label"))
                    .font(.caption).bold()
                    .foregroundColor(edited ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(edited ? Color.yellow : Color.black)
                    .cornerRadius(6)
                    .fixedSize()
                    .offset(x: 12, y: -14)
                    .zIndex(1)
            }

            // No extra explanatory text here per request; provide info button if desired
        }
    }
}
