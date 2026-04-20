import SwiftUI

// MARK: - ColorSelectionView
 struct ColorSelectionView: View {
    @Binding var selectedColorName: String
    @Binding var selectedColorColor: Color
    @Binding var isColorSelected: Bool
    @Binding var showColorPickerOverlay: Bool
    @Binding var customColor: Color
    @Binding var customColors: [String]
    @Binding var hexColor: String
    
    let colorNames: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Basis parameters - pas aan indien nodig
            let cornerRadius: CGFloat = 12
            let fieldHeight: CGFloat = 48
            
            Menu {
                ForEach(colorNames, id: \.self) { colorName in
                    Button {
                        selectedColorName = colorName
                        selectedColorColor = getColorForName(colorName)
                        customColor = selectedColorColor
                        isColorSelected = true
                    } label: {
                        Label {
                            Text(colorName).foregroundColor(.primary)
                        } icon: {
                            Image(systemName: "circle.fill")
                                .symbolRenderingMode(.palette)
                                .foregroundStyle(getColorForName(colorName), .primary)
                                .frame(width: 16, height: 16)
                        }
                    }
                    .background(
                        RoundedRectangle(cornerRadius:12)
                            .fill(Color.gray.opacity(0.4))
                            .overlay(RoundedRectangle(cornerRadius:12).stroke(isColorSelected ? Color.yellow : Color.gray, lineWidth:3))
                    )
                }
                
                Button {
                    showColorPickerOverlay = true
                    selectedColorName = NSLocalizedString("color_picker.title", comment: "Color picker")
                } label: {
                    Label(NSLocalizedString("color_picker.title", comment: "Color picker"), systemImage: "paintpalette")
                }
            } label: {
                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        HStack {
                            if selectedColorName == NSLocalizedString("color_picker.title", comment: "Color picker") {
                                Image(systemName: "paintpalette")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 20, height: 20)
                                    .symbolRenderingMode(.palette)
                                    .foregroundStyle(customColor, .white)
                            } else {
                                Circle()
                                    .fill(selectedColorColor)
                                    .frame(width: 20, height: 20)
                                    .overlay(Circle().stroke(Color.gray.opacity(0.5), lineWidth: 1))
                            }

                            Text(selectedColorName)
                                .font(.body.bold())
                                .foregroundColor(.white)
                            Spacer()
                            Image(systemName: "chevron.down").foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.4))
                        .overlay(
                            RoundedRectangle(cornerRadius: cornerRadius)
                                .stroke(isColorSelected ? Color.yellow : Color.gray, lineWidth: 3)
                        )

                        // Zwevend badge "Kleur"
                        Text(NSLocalizedString("color.title", comment: "Color"))
                            .font(.caption).bold()
                            .foregroundColor(isColorSelected ? Color.black : Color.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(isColorSelected ? Color.yellow : Color.black)
                            .cornerRadius(6)
                            .fixedSize()
                            .offset(x: 20, y: -12)
                            .zIndex(1)
                    }
                    .frame(height: fieldHeight)
                }
                .frame(height: fieldHeight)
            }
        }
        .padding(.top, 12)
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 4)
    }

    // Helper for menu item background (optional)
    private func filledBackground(for colorName: String) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.4))
            .overlay(RoundedRectangle(cornerRadius: 12)
            .stroke(isColorSelected && selectedColorName == colorName ? Color.yellow : Color.gray, lineWidth: 3))
    }
    
    
}
