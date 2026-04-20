import Foundation

struct Filament: Identifiable, Hashable, Decodable {
    let id: Int
    let registered: String?
    let name: String
    let vendor: Vendor?
    let material: String?
    let price: Double?
    let density: Double?
    let diameter: Double?
    let weight: Double?
    let spool_weight: Double?
    let article_number: String?
    let settings_extruder_min_temp: Int?
    let settings_extruder_max_temp: Int?
    let settings_bed_min_temp: Int?
    let settings_bed_max_temp: Int?
    let color_hex: String?
    let extra: [String: String]?
}

struct Vendor: Decodable, Hashable {
    let id: Int
    let registered: String?
    let name: String
    let empty_spool_weight: Double?
    let extra: [String: String]?
}
