import SwiftUI

extension View {
    func simplePlaceholder(_ text: String, when shouldShow: Bool) -> some View {
        ZStack(alignment: .leading) {
            if shouldShow {
                Text(text)
                    .foregroundColor(Color.white.opacity(0.6))
                    .padding(.horizontal, 20)
                    .padding(.vertical, 16)
            }
            self
        }
    }
}

// MARK: - SettingsView (updated)
struct SettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @AppStorage("spoolmanURL") private var spoolmanIP: String = ""
    @AppStorage("currency") private var storedCurrency: String = ""
    @FocusState private var focusedField: Bool
    // removed hasUserEdited

    private let urlExample = "http://192.168.1.10:7912 or http://192.168.1.10:8000"
    private let cornerRadius: CGFloat = 12
    private let fieldHeight: CGFloat = 48
    private let badgePadH: CGFloat = 8
    private let badgePadV: CGFloat = 4

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            VStack(spacing: 24) {
                HStack {
                    Text(NSLocalizedString("spoolman.settings", comment: "Settings text"))
                        .font(.headline.weight(.semibold))
                        .foregroundColor(.white)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .contentShape(Rectangle())
                        .onTapGesture { dismiss() }
                    Spacer()
                }

                GeometryReader { geo in
                    ZStack(alignment: .topLeading) {
                        RoundedRectangle(cornerRadius: cornerRadius)
                            .fill(Color.black)
                            .frame(height: fieldHeight)
                            .overlay(
                                RoundedRectangle(cornerRadius: cornerRadius)
                                    .stroke(focusedField ? Color.yellow : Color.gray.opacity(0.9), lineWidth: 3)
                            )

                        // show example while focused AND spoolmanIP is empty
                        HStack {
                            Text((focusedField && spoolmanIP.isEmpty) ? urlExample : (spoolmanIP.isEmpty ? "" : spoolmanIP))
                                .font(.caption.bold())
                                .foregroundColor((focusedField && spoolmanIP.isEmpty) ? Color.gray : Color.white)
                                .lineLimit(1)
                                .truncationMode(.tail)
                                .padding(.leading, 20)
                                .zIndex(2)
                            Spacer()
                        }
                        .frame(height: fieldHeight)

                        if !focusedField && spoolmanIP.isEmpty {
                            Text("Spoolman URL")
                                .foregroundColor(Color.white.opacity(0.6))
                                .padding(.leading, 20)
                                .frame(height: fieldHeight)
                                .zIndex(1)
                        }

                        // TextField: bind directly to spoolmanIP; while showing example we return empty so the example remains visual
                        TextField("", text: Binding(
                            get: {
                                if focusedField && spoolmanIP.isEmpty { return "" }
                                return spoolmanIP
                            },
                            set: { newValue in
                                spoolmanIP = newValue
                            }
                        ))
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.never)
                        .focused($focusedField)
                        .font(.caption.bold())                // belangrijk: match de overlay font
                            .foregroundColor(Color.white.opacity(0.01)) // nearly invisible but measurable
                            .accentColor(.white)                  // caret color
                            .padding(.horizontal, 20)             // match the overlay padding
                        .frame(height: fieldHeight)
                        .background(Color.clear)
                        .zIndex(3)

                        Text("Spoolman Server URL")
                            .font(.caption).bold()
                            .foregroundColor(focusedField ? Color.black : Color.white)
                            .padding(.horizontal, badgePadH)
                            .padding(.vertical, badgePadV)
                            .background(focusedField ? Color.yellow : Color.black)
                            .cornerRadius(6)
                            .fixedSize()
                            .position(x: badgeX(in: geo.size.width, cornerRadius: cornerRadius),
                                      y: badgeY(fieldHeight: fieldHeight))
                            .zIndex(4)
                    }
                    .frame(height: fieldHeight)
                }
                .frame(height: fieldHeight)
                .padding(.horizontal)

                HStack {
                    Text("\(spoolmanIP.count)/50")
                        .font(.caption2.weight(.semibold))
                        .foregroundColor(.white.opacity(0.7))
                    Spacer()
                }
                .padding(.horizontal)

                HStack {
                    Text(NSLocalizedString("spoolman.text", comment: "Text for filling in URL"))
                        .font(.caption)
                        .foregroundColor(.white.opacity(0.6))
                    Spacer()
                }
                .padding(.horizontal)
                
                // Currency picker (keeps original AppStorage behaviour)
                HStack {
                    Text("Valuta").foregroundColor(.white)
                    Spacer()
                    Picker("", selection: $storedCurrency) {
                        Text("€").tag("€")
                        Text("$").tag("$")
                        Text("£").tag("£")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .tint(.yellow)
                    .frame(width: 180)
                }
                .padding(.horizontal)
                                

                HStack(spacing: 8) {
                    Button(NSLocalizedString("spoolman.button.cancel", comment: "Cancel button")) { dismiss() }
                        .font(.system(size: 20, weight: .semibold))
                        .controlSize(.regular)
                        .frame(height: 44).frame(width: 120)
                        .foregroundStyle(.yellow)
                        .background(.black)
                        .clipShape(.capsule)
                        .overlay(RoundedRectangle(cornerRadius: 60).stroke(.white, lineWidth: 2))

                    Spacer()

                    Button(NSLocalizedString("spoolman.button.save", comment: "Save button")) {
                        var s = spoolmanIP.trimmingCharacters(in: .whitespacesAndNewlines)
                        if s.isEmpty { return dismiss() }
                        if !s.hasPrefix("http://") && !s.hasPrefix("https://") { s = "http://\(s)" }
                        spoolmanIP = s
                        dismiss()
                    }
                    .font(.system(size: 20, weight: .semibold))
                    .controlSize(.regular)
                    .frame(height: 44).frame(width: 120)
                    .foregroundStyle(.white)
                    .background(.yellow).tint(.white)
                    .clipShape(.capsule)
                }
                .padding(.top, 8)
                .padding(.horizontal, 20)

                Spacer()
            }
            .padding(.top, 32)
        }
        .onTapGesture {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    }

    private func badgeX(in totalWidth: CGFloat, cornerRadius: CGFloat) -> CGFloat {
        let leftPadding: CGFloat = 80
        let extraOffset: CGFloat = 8
        return leftPadding + cornerRadius / 2 + extraOffset
    }

    private func badgeY(fieldHeight: CGFloat) -> CGFloat { 0 }
}
