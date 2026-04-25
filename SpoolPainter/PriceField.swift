import SwiftUI

struct PriceField: View {
    @Binding var price: String
    @Binding var currency: String
    @Binding var edited: Bool
    var keyboard: UIKeyboardType = .numbersAndPunctuation

    @FocusState private var isPriceFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                HStack {
                    Text(currency.isEmpty ? "€" : currency)
                        .font(.body)
                        .padding(.leading, 12)
                    
                    TextField("", text: $price)
                        .keyboardType(keyboard)
                        .focused($isPriceFocused)
                        .padding(.vertical, 12)
                        .overlay(
                            Group {
                                if price.isEmpty {
                                    Text("0.00")
                                        .foregroundColor(Color.white.opacity(0.6))
                                        .padding(.leading, 8)  // ← 8 points works perfectly
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                            }
                        )
                    
                    Spacer()
                }
                .frame(height: 48)
                .frame(maxWidth: .infinity)
                .background(Color.gray.opacity(0.15))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(edited ? Color.yellow : Color.gray, lineWidth: 2)
                )
                .onChange(of: price) { _, newValue in
                    let cleaned = newValue.replacingOccurrences(of: "\n", with: "")
                                          .replacingOccurrences(of: ",", with: ".")
                                          .replacingOccurrences(of: "€", with: "")
                                          .replacingOccurrences(of: "$", with: "")
                                          .replacingOccurrences(of: "£", with: "")
                                          .trimmingCharacters(in: .whitespaces)
                    price = cleaned
                    if !edited { edited = true }
                }
                
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
        }
    }
}
