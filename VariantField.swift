import SwiftUI

// MARK: - VariantField
 struct VariantField: View {
    //@Binding private var text = ""
    @Binding var variantText: String
    var variantFocused: FocusState<Bool>.Binding
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            GeometryReader { geo in
                // Basis parameters - pas aan indien nodig
                let cornerRadius: CGFloat = 12
                let fieldHeight: CGFloat = 48
                
                
                ZStack(alignment: .topLeading) {
                    TextField(NSLocalizedString("variant-placeholder", comment: "Placeholder"), text: $variantText)
                        .padding(14)
                        .padding(.vertical, (fieldHeight - 16) / 2)
                        .frame(height: fieldHeight)
                        .background(Color.gray.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(variantText.isEmpty ? Color.gray : Color.yellow, lineWidth: 3)
                        )
                        .focused(variantFocused)
                        .lineLimit(1)
                        .textFieldStyle(PlainTextFieldStyle())
                        .foregroundColor(variantText.isEmpty ? .gray : .white)
                    
                    // Zwevend badge
                    Text("Variant")
                        .font(.caption).bold()
                        .foregroundColor(variantText.isEmpty ? Color.white : Color.black)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(variantText.isEmpty ? Color.black : Color.yellow)
                        .cornerRadius(6)
                        .fixedSize() // voorkomt dat het badge de parent-layout verandert
                        .position(x: badgeX(in: geo.size.width, cornerRadius: cornerRadius),
                                  y: badgeY(fieldHeight: fieldHeight))
                        .zIndex(1)
                }
                .frame(height: fieldHeight)
            }
            .frame(height: 44) // vaste hoogte voor stabiele layout
        }
        .padding(.top, 6)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
    // Helper functies voor badge positionering
    private func badgeX(in totalWidth: CGFloat, cornerRadius: CGFloat) -> CGFloat {
        // Zet badge net na de eerste bocht: hoek + padding
        // 20 is dezelfde horizontal padding als in HStack
        let leftPadding: CGFloat = 35
        // extra offset van de hoek zodat de badge niet te veel in de bocht valt
        let extraOffset: CGFloat = 8
        return leftPadding + cornerRadius / 2 + extraOffset
    }
    
    private func badgeY(fieldHeight: CGFloat) -> CGFloat {
        // Plaats de badge zo dat deze gedeeltelijk boven op de rand zweeft.
        // Kies y < (fieldHeight / 2) zodat het boven de top van het field komt.
        return 0 // position y=0 in combinatie met .position() interpreteert y relativ aan view top,
        // we willen het net boven de bovenkant van de RoundedRectangle, dus gebruik 0 en let op padding via .frame hoogte
    }
}
