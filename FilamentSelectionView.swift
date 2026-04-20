import SwiftUI


 // MARK: - FilamentSelectionView
        struct FilamentSelectionView: View {
            
            @Binding var filament: String
            @Binding var customMaterial: String
            @Binding var isOtherSelected: Bool
            @Binding var isSelected: Bool
            let allFilaments: [String]
            
            var body: some View {
                
                HStack(spacing: 16) {
                    Menu {
                        ForEach(allFilaments.indices, id: \.self) { index in
                            Button(allFilaments[index]) {
                                filament = allFilaments[index]
                                customMaterial = ""
                                isOtherSelected = (filament == NSLocalizedString("filament", comment: "Text for other"))
                                isSelected = (filament == "PLA") || (filament == NSLocalizedString("filament", comment: "Text for other"))
                            }
                        }
                        
                    } label: {
                        GeometryReader { geo in
                            // Basis parameters - pas aan indien nodig
                            let cornerRadius: CGFloat = 12
                            let fieldHeight: CGFloat = 48
                            let badgePaddingHorizontal: CGFloat = 8
                            let badgePaddingVertical: CGFloat = 4
                            
                            ZStack(alignment: .topLeading) {
                                
                                // Basis van het selection field
                                HStack {
                                    Text(filament)
                                        .font(.body.bold())
                                        .foregroundColor(.white)
                                        .background(Color.clear)
                                    Spacer()
                                    Image(systemName: "chevron.down")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, (fieldHeight - 16) / 2) // vertical padding passend bij fieldHeight
                                .frame(height: fieldHeight)
                                .frame(maxWidth: .infinity)
                                .background(Color.gray.opacity(0.4))
                                .overlay(
                                    RoundedRectangle(cornerRadius: cornerRadius)
                                        .stroke(isSelected ? Color.yellow : Color.gray, lineWidth: 3)
                                )
                                .id(filament)
                                // Zwevend badge: meet breedte van badge en positioneer relatief aan radius
                                Text("Filament")
                                    .font(.caption).bold()
                                    .foregroundColor(isSelected ? Color.black : Color.white)
                                    .padding(.horizontal, badgePaddingHorizontal)
                                    .padding(.vertical, badgePaddingVertical)
                                    .background(isSelected ? Color.yellow : Color.black)
                                    .cornerRadius(6)
                                    .fixedSize() // voorkomt dat het badge de parent-layout verandert
                                    .position(x: badgeX(in: geo.size.width, cornerRadius: cornerRadius),
                                              y: badgeY(fieldHeight: fieldHeight))
                                    .zIndex(1)
                            }
                            // Zorg dat GeometryReader zelf een vaste hoogte heeft zodat parent HStack niet shrinkt
                            .frame(height: fieldHeight)
                        }
                        // GeometryReader neemt automatisch zoveel hoogte, beperk deze zodat HStack layout stabiel blijft
                        .frame(height: 48)
                    }
                    .onChange(of: filament) { oldValue, newValue in
                        isSelected = newValue == "PLA" || newValue != "Soort filament"
                    }
                    
                    // TextField - ALLEEN als isOtherSelected TRUE
                    if isOtherSelected {
                        TextField(NSLocalizedString("filament.kind", comment: "Kind of filament"), text: $customMaterial)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 14)
                            .background(Color.black)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(customMaterial.isEmpty ? Color.gray : Color.yellow, lineWidth: 3)
                            )
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.top, 6)
                .frame(maxWidth: .infinity)
                .padding(.horizontal, 4)
                //.padding(.horizontal)
            }
            
            // Helper functies voor badge positionering
            private func badgeX(in totalWidth: CGFloat, cornerRadius: CGFloat) -> CGFloat {
                // Zet badge net na de eerste bocht: hoek + padding
                // 20 is dezelfde horizontal padding als in HStack
                let leftPadding: CGFloat = 40
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
