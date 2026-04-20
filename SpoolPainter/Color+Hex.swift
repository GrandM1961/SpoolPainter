import SwiftUI
import UIKit

extension Color {
    init(hex: String) {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        guard !hexSanitized.isEmpty else {
            self.init(red: 1, green: 1, blue: 1); return
        }
        var rgb: UInt64 = 0
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        let red = Double((rgb >> 16) & 0xFF) / 255.0
        let green = Double((rgb >> 8) & 0xFF) / 255.0
        let blue = Double(rgb & 0xFF) / 255.0
        self.init(red: red, green: green, blue: blue)
    }

    // detecteer bijna-zwart en geef een iets lichtere Color terug (gebruiks-only)
    func lighterIfNearlyBlack(fallbackAmount: Double = 0.12, threshold: Double = 0.05) -> Color {
        #if canImport(UIKit)
        let ui = UIColor(self)
        var r: CGFloat=0,g: CGFloat=0,b: CGFloat=0,a: CGFloat=0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return self }
        let luminance = 0.299*Double(r) + 0.587*Double(g) + 0.114*Double(b)
        if luminance > threshold { return self }
        let nr = min(1.0, Double(r) + fallbackAmount)
        let ng = min(1.0, Double(g) + fallbackAmount)
        let nb = min(1.0, Double(b) + fallbackAmount)
        return Color(red: nr, green: ng, blue: nb, opacity: Double(a))
        #else
        return self
        #endif
    }
    #if canImport(UIKit)
    func toHexString() -> String? {
        let ui = UIColor(self)
        var r: CGFloat=0, g: CGFloat=0, b: CGFloat=0, a: CGFloat=0
        guard ui.getRed(&r, green: &g, blue: &b, alpha: &a) else { return nil }
        let ri = Int(round(r * 255)), gi = Int(round(g * 255)), bi = Int(round(b * 255))
        return String(format:"#%02X%02X%02X", ri, gi, bi)
    }

    #endif
}
