import SwiftUI

struct LabeledField: View {
@Binding var text: String
@Binding var edited: Bool
let title: String
var infoTitle: String? = nil
var infoText: String? = nil
var badgeOffsetX: CGFloat = 12
var badgeOffsetY: CGFloat = -14
var placeholder: String = ""
var keyboard: UIKeyboardType = .numbersAndPunctuation

    @State private var showingInfoAlert = false

    var body: some View {
        let cornerRadius: CGFloat = 12
        let fieldHeight: CGFloat = 48

        VStack(alignment: .leading, spacing: 6) {
            ZStack(alignment: .topLeading) {
                TextField("", text: $text)
                    .keyboardType(keyboard)
                    .padding(.horizontal, 12)
                    .padding(.vertical, (fieldHeight - 16) / 2)
                    .frame(height: fieldHeight)
                    .frame(maxWidth: .infinity)
                    .background(Color.gray.opacity(0.15))
                    .overlay(
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .stroke(edited ? Color.yellow : Color.gray, lineWidth: 2)
                    )
                    .onChange(of: text) {_, newValue in
                    print("LabeledField '\(title)' onChange newValue='\(newValue)'")
                    let v = newValue.replacingOccurrences(of: "\n", with: "")
                    if v != newValue { text = v }
                    if !edited { edited = true }
                    }
                    .simplePlaceholder(placeholder, when: text.isEmpty)

                Text(title)
                    .font(.caption).bold()
                    .foregroundColor(edited ? Color.black : Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(edited ? Color.yellow : Color.black)
                    .cornerRadius(6)
                    .fixedSize()
                    .offset(x: badgeOffsetX, y: badgeOffsetY)
                    .zIndex(1)
            }
            
            if let infoText = infoText, let infoTitle = infoTitle {
                HStack(alignment: .center, spacing: 8) {
                    Button(action: { showingInfoAlert = true }) {
                        Text("!")
                            .font(.footnote).bold()
                            .foregroundColor(.black)
                            .frame(width: 26, height: 26)
                            .background(Color.yellow)
                            .clipShape(Circle())
                    }
                    .buttonStyle(PlainButtonStyle())
                    .accessibilityLabel(NSLocalizedString("labeledfield.info", comment: "labeledfield more information"))
                    .alert(isPresented: $showingInfoAlert) {
                        Alert(
                            title: Text(infoTitle),
                            message: Text(infoText),
                            dismissButton: .default(Text(NSLocalizedString("labeledfield.close", comment: "labeledfield sluiten")))
                        )
                    }

                    Text("Info \(infoTitle)")
                        .font(.footnote)
                        .foregroundColor(.secondary)
                        .padding(.top, 10)
                        .padding(.bottom, 0)

                    Spacer()
                }
            }
        }
    }
}
