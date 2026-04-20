import SwiftUI
import UIKit

func normalizeHex(_ s: String) -> String {
    let chars = s.uppercased().filter { "#0123456789ABCDEF".contains($0) }
    if chars.first == "#" {
        return String(chars)
    } else {
        return "#" + String(chars)
    }
}

fileprivate struct ColorModel {
    var hue: Double    // 0...1
    var saturation: Double // 0...1
    var brightness: Double // 0...1
    var alpha: Double = 1.0

    var color: Color {
        Color(hue: hue, saturation: saturation, brightness: brightness, opacity: alpha)
    }

    var hex: String {
        let ui = UIColor(self.color)
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getRed(&r, green: &g, blue: &b, alpha: &a)
        return String(format: "#%02X%02X%02X", Int(r * 255), Int(g * 255), Int(b * 255))
    }

    static func from(color: Color) -> ColorModel {
        let ui = UIColor(color)
        var h: CGFloat = 0, s: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        ui.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        return ColorModel(hue: Double(h), saturation: Double(s), brightness: Double(b), alpha: Double(a))
    }

    static func from(hex: String) -> ColorModel? {
        var hexStr = hex.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        if hexStr.hasPrefix("#") { hexStr.removeFirst() }
        guard hexStr.count == 6, let intVal = Int(hexStr, radix: 16) else { return nil }
        let r = Double((intVal >> 16) & 0xFF) / 255.0
        let g = Double((intVal >> 8) & 0xFF) / 255.0
        let b = Double(intVal & 0xFF) / 255.0
        let color = Color(red: r, green: g, blue: b)
        return ColorModel.from(color: color)
    }
}

struct ColorPickerView: View {
    @Binding var selectedColor: Color          // now binds to customColor in ContentView
    @Binding var showColorPicker: Bool
    @Binding var customColors: [String]
    @Binding var hexCode: String
    @Binding var isColorSelected: Bool

    @State private var editingHex: String = ""
    @State private var colorModel: ColorModel = ColorModel(hue: 0, saturation: 0, brightness: 1.0)

    private func syncOut() {
        selectedColor = colorModel.color
        hexCode = colorModel.hex
    }

    private func syncIn() {
        colorModel = ColorModel.from(color: selectedColor)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                VStack(spacing: 4) {
                    Text(NSLocalizedString("color_picker.title", comment: "Title of Color Picker"))
                        .font(.title2)
                        .fontWeight(.semibold)
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(height: 1)
                }
                .padding(.horizontal)
                .padding(.top)

                // Hex code field and color box
                HStack(spacing: 8) {
                    Text("Hex Code")
                        .font(.caption)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 8)

                    TextField("#FFFFFF", text: Binding(
                        get: { hexCode },
                        set: { newHex in
                            hexCode = newHex
                            if let m = ColorModel.from(hex: newHex) {
                                colorModel = m
                                syncOut()
                            }
                        })
                    )
                    .font(.system(.body, design: .monospaced))
                    .autocapitalization(.allCharacters)
                    .disableAutocorrection(true)
                    .foregroundColor(.black)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 10)
                    .background(Color.white)
                    .cornerRadius(8)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(Color.gray.opacity(0.8), lineWidth: 2))
                    .submitLabel(.done)
                    .onSubmit {
                        let normalized = normalizeHex(editingHex)
                        editingHex = normalized
                        if let m = ColorModel.from(hex: normalized) {
                            colorModel = m
                            selectedColor = colorModel.color
                            hexCode = colorModel.hex
                        }
                    }
                    .onChange(of: editingHex) { oldValue, newValue in
                        let cleaned = newValue.uppercased().filter { "0123456789ABCDEF#".contains($0) }
                        let stripped = cleaned.hasPrefix("#") ? String(cleaned.dropFirst()) : cleaned
                        if stripped.count == 6 {
                            let candidate = "#" + stripped
                            if let m = ColorModel.from(hex: candidate) {
                                colorModel = m
                                syncOut()
                                editingHex = candidate
                            }
                        }
                    }
                    .onAppear { editingHex = colorModel.hex }

                    RoundedRectangle(cornerRadius: 8)
                        .fill(colorModel.color)
                        .frame(width: 60, height: 60)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.gray.opacity(0.8), lineWidth: 1)
                        )
                }
                .padding(.horizontal)
                .padding(.top, 10)

                // Color Wheel (bind hue & saturation)
                ColorWheelView(hue: $colorModel.hue, saturation: $colorModel.saturation)
                    .frame(width: 200, height: 200)
                    .padding(.top, 30)
                    .onChange(of: colorModel.hue) { _, _ in
                        selectedColor = colorModel.color
                        hexCode = colorModel.hex
                    }
                    .onChange(of: colorModel.saturation) { _, _ in
                        selectedColor = colorModel.color
                        hexCode = colorModel.hex
                    }

                // Brightness slider
                VStack(alignment: .leading, spacing: 8) {
                    Text(NSLocalizedString("color_picker.brightness", comment: "Brightness of Color Picker"))
                        .font(.caption)
                        .foregroundColor(.white)
                    HStack(spacing: 12) {
                        Rectangle()
                            .fill(Color.black)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)

                        Slider(value: Binding(
                            get: { colorModel.brightness },
                            set: { newVal in
                                colorModel.brightness = newVal
                                selectedColor = colorModel.color
                                hexCode = colorModel.hex
                            }
                        ), in: 0...1)
                        .accentColor(Color.yellow)
                        .frame(height: 6)
                        .cornerRadius(2)
                        .padding()

                        Rectangle()
                            .fill(Color.white)
                            .frame(width: 20, height: 20)
                            .cornerRadius(4)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                            )
                    }
                }
                .padding(.horizontal)
                .padding(.top, 30)

                // Buttons
                HStack(spacing: 26) {
                    Button(NSLocalizedString("color_picker.cancel", comment: "Cancel Button")) {
                        showColorPicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.gray.opacity(0.2))
                    .foregroundColor(.yellow)
                    .cornerRadius(10)

                           Button(NSLocalizedString("color_picker.done", comment: "Done button")) {
                        syncOut()
                        withAnimation(.easeInOut(duration: 0.25)) {
                            selectedColor = colorModel.color
                            isColorSelected = true
                        }
                        showColorPicker = false
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 8)
                    .background(Color.yellow)
                    .foregroundColor(.black)
                    .cornerRadius(10)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
            }
            .background(Color.gray.opacity(0.4))
            .onAppear {
                syncIn()
                editingHex = colorModel.hex
            }
        }
    }
}
