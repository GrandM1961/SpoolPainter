import SwiftUI

// MARK: - Color matching helper (file-level, buiten structs)
 func getColorForName(_ name: String) -> Color {
    let n = name.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    // directe hex check
    if n.hasPrefix("#") { return Color(hex: name) }
    // probeer lookup via colorMap keys of localized names
    let lookup = n.replacingOccurrences(of: " ", with: "")
    if let mapped = colorMap[lookup] { return mapped }
    // Engelse/NIederlandse/Duitse en algemene keywords
    switch n {
    case "white", "wit", "weiß", "weiss": return .white
    case "black", "zwart", "schwarz": return .black
    case "red", "rood", "rot": return .red
    case "blue", "blauw", "blau": return .blue
    case "green", "groen", "grün", "grun": return .green
    case "yellow", "geel", "gelb": return .yellow
    case "gray", "grey", "grijs", "grau": return .gray
    case "orange", "oranje": return .orange
    case "purple", "paars", "lila": return .purple
    case "pink", "roze", "rosa": return .pink
    case "brown", "bruin", "braun": return Color.brown
    case "silver", "zilver", "silber": return Color(white: 0.78)
    case "gold", "goud": return Color(red: 0.83, green: 0.69, blue: 0.22)
    default:
        // fallback: try hex via colorLookupCache (keys lowercased)
        let base = baseColorToken(from: name).lowercased()
        if let hex = colorLookupCache[base] {
            return Color(hex: hex) // verwacht "#RRGGBB" of "RRGGBB"
        }
        return .clear
    }
}

 func colorFromHexOrName(_ hex: String?, nameList: [String]) -> (name: String, color: Color) {
    guard let hex = hex?.trimmingCharacters(in: .whitespacesAndNewlines), !hex.isEmpty else {
        return ("Wit", .white)
    }
    let cleaned = hex.replacingOccurrences(of: "#", with: "").uppercased()
    // Probeer match op vaste namen via hun hex-waarden (gebruik je Color.toHexString())
    for name in nameList {
        if let nameHex = getColorForName(name).toHexString()?.replacingOccurrences(of: "#", with: "").uppercased(),
           nameHex == cleaned {
            return (name, getColorForName(name))
        }
    }
    // Geen naam match: retourneer kleurkiezer met de geconverteerde kleur
    return ("Kleurkiezer", Color(hex: "#" + cleaned))
}

private let colorMap: [String: Color] = [
  "color.white": .white, "color.black": .black, "color.red": .red,
  "color.blue": .blue, "color.green": .green, "color.yellow": .yellow,
  "color.gray": .gray, "color.orange": .orange, "color.purple": .purple,
  "color.pink": .pink
]

enum AppLanguage { case nl, en, de }

var currentAppLanguage: AppLanguage {
    // First, check if user manually selected a language in your app
    if let savedLanguage = UserDefaults.standard.string(forKey: "appLanguage") {
        switch savedLanguage {
        case "de": return .de
        case "en": return .en
        default: return .nl
        }
    }
    
    // If no manual selection, use the device's system language
    let systemLanguage = Locale.current.language.languageCode?.identifier ?? "en"
    switch systemLanguage {
    case "de": return .de
    case "en": return .en
    case "nl": return .nl
    default: return .en  // Default to English for other languages
    }
}

func loadCodeHexDictionary() -> [String: String] {
    if let url = Bundle.main.url(forResource: "code+Hex", withExtension: "json"),
       let data = try? Data(contentsOf: url),
       let dict = try? JSONSerialization.jsonObject(with: data) as? [String: String] {
        var normalized: [String: String] = [:]
        for (k, v) in dict { normalized[k.lowercased()] = v }
        return normalized
    }
    return [:]
}

// laad één keer
let colorLookupCache: [String: String] = loadCodeHexDictionary()

func baseColorToken(from name: String) -> String {
    let raw = name.trimmingCharacters(in: .whitespacesAndNewlines)
    let separators = CharacterSet(charactersIn: "+-|/,")
    var normalized = raw.components(separatedBy: separators).joined(separator: " ")
    while normalized.contains("  ") { normalized = normalized.replacingOccurrences(of: "  ", with: " ") }
    normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
    let parts = normalized.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
    return parts.last ?? normalized
}

func localizedColorName(for token: String, lang: AppLanguage) -> String {
    let key = token.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
    let mapNL: [String: String] = ["black":"Zwart","white":"Wit","red":"Rood","blue":"Blauw","green":"Groen","yellow":"Geel","orange":"Oranje","pink":"Roze","purple":"Paars","brown":"Bruin","gray":"Grijs","grey":"Grijs","silver":"Zilver","gold":"Goud"]
    let mapDE: [String: String] = ["black":"Schwarz","white":"Weiß","red":"Rot","blue":"Blau","green":"Grün","yellow":"Gelb","orange":"Orange","pink":"Rosa","purple":"Lila","brown":"Braun","gray":"Grau","grey":"Grau","silver":"Silber","gold":"Gold"]
    switch lang {
    case .nl: return mapNL[key] ?? key.capitalized
    case .de: return mapDE[key] ?? key.capitalized
    case .en: return key.capitalized
    }
}
