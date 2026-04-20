import SwiftUI

// MARK: - BrandSelectionView
 struct BrandSelectionView: View {
    //@State private var text = ""
    @Binding var brand: String
    @Binding var customBrand: String
    @Binding var isOtherBrand: Bool
    @Binding var scannedBrand: String
    @Binding var isBrandSelected: Bool
    let allBrands: [String]
    
    // Pas deze waarden om de badge te positioneren
        @State private var badgeOffsetX: CGFloat = 16
        @State private var badgeOffsetY: CGFloat = -12
    
    var body: some View {
        HStack(spacing: 16) {
            
            Menu {
                ForEach(allBrands.indices, id: \.self) { index in
                    Button(allBrands[index]) {
                        brand = allBrands[index]
                        customBrand = ""
                        isOtherBrand = (brand == NSLocalizedString("isOtherBrand", comment: "Text for other"))
                        isBrandSelected = (brand == NSLocalizedString("isBrandSelected", comment: "Text for generic")  || brand == "Ander")
                    }
                }
            } label: {
                GeometryReader { geo in
                    let cornerRadius: CGFloat = 12
                    let fieldHeight: CGFloat = 48
                    let leftPadding: CGFloat = 20

                    ZStack(alignment: .topLeading) {
                        HStack {
                            Text(brand)
                                .font(.body.bold())
                                .foregroundColor(.white)
                                .background(Color.clear)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, leftPadding)
                        .padding(.vertical, (fieldHeight - 16) / 2)
                        .frame(height: fieldHeight)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(isBrandSelected ? Color.yellow : Color.gray, lineWidth: 3)
                        )

                        // Zwevend badge "Merk"
                        Text(NSLocalizedString("brand", comment: "Textfield Brand"))
                            .font(.caption).bold()
                            .foregroundColor(isBrandSelected ? Color.black : Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isBrandSelected ? Color.yellow : Color.black)
                            .cornerRadius(6)
                            .fixedSize()
                            .offset(x: 20, y: -12)
                            .zIndex(1)
                    }
                    .frame(height: fieldHeight)
                }
                .frame(height: 48)
            }
            .onChange(of: brand) {oldValue,  newValue in
                isBrandSelected = newValue != "Selecteer Merk"
            }
                                    
            
            // TextField - ALLEEN als isOtherSelected TRUE
            if isOtherBrand {
                TextField(NSLocalizedString("brandname", comment: "Fill in new Brand name"), text: $customBrand)
                    .padding(.horizontal, 20)
                    .padding(.vertical, 14)
                    .background(Color.black)
                    .foregroundColor(.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(customBrand.isEmpty ? Color.gray : Color.yellow, lineWidth: 3)
                    )
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }
}
