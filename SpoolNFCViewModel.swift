
import SwiftUI
import Combine
import Foundation
import CoreNFC

// MARK: - Errors
    enum OpenSpoolError: Error, LocalizedError {
        case invalidJSON
        case missingProtocolOrVersion
        case protocolMismatch
        case versionMismatch
        case tooLargeForTag(maxBytes: Int)


var errorDescription: String? {
    switch self {
    case .invalidJSON: return "Invalid JSON for OpenSpool."
    case .missingProtocolOrVersion: return "Missing protocol or version."
    case .protocolMismatch: return "Protocol mismatch (expected 'openspool')."
    case .versionMismatch: return "Version mismatch."
    case .tooLargeForTag(_): return "Message too large for tag capacity ((max) bytes)."
    }
}
}
// MARK: - Model
struct OpenSpool: Codable, Identifiable, Equatable {
    let id: Int?
    let protocolName: String?
    let version: String?
    let brand: String?
    let type: String?
    let subtype: String?
    let color_hex: String?
    let additional_color_hexes: [String]?
    let alpha: String?
    
    
    let min_temp: Int?
    let max_temp: Int?
    let bed_min_temp: Int?
    let bed_max_temp: Int?
    var weight: Double?
    var spoolweight: Double?
    var density: Double?
    let price: Double?
    let lot_nr: String?
    let diameter: Double?
    let currency: String?
    
    enum CodingKeys: String, CodingKey {
        case id
        case protocolName = "protocol"
        case version
        case brand, type, subtype, color_hex, additional_color_hexes, alpha
        case min_temp, max_temp, bed_min_temp, bed_max_temp, weight, spoolweight
        case density, price, currency, lot_nr, diameter
    }
    
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        
        func decodeIntFlexible(_ key: CodingKeys) -> Int? {
            if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) { return intVal }
            if let strVal = try? c.decodeIfPresent(String.self, forKey: key), let v = Int(strVal) { return v }
            return nil
        }
        func decodeDoubleFlexible(_ key: CodingKeys) -> Double? {
            if let doubleVal = try? c.decodeIfPresent(Double.self, forKey: key) { return doubleVal }
            if let intVal = try? c.decodeIfPresent(Int.self, forKey: key) { return Double(intVal) }
            if let strVal = try? c.decodeIfPresent(String.self, forKey: key), let v = Double(strVal) { return v }
            return nil
        }
        
        if let intId = try? c.decodeIfPresent(Int.self, forKey: .id) {
            id = intId
        } else if let strId = try? c.decodeIfPresent(String.self, forKey: .id), let i = Int(strId) {
            id = i
        } else {
            id = nil
        }
        protocolName = try? c.decodeIfPresent(String.self, forKey: .protocolName)
        version = try? c.decodeIfPresent(String.self, forKey: .version)
        brand = try? c.decodeIfPresent(String.self, forKey: .brand)
        type = try? c.decodeIfPresent(String.self, forKey: .type)
        subtype = try? c.decodeIfPresent(String.self, forKey: .subtype)
        color_hex = try? c.decodeIfPresent(String.self, forKey: .color_hex)
        additional_color_hexes = try? c.decodeIfPresent([String].self, forKey: .additional_color_hexes)
        alpha = try? c.decodeIfPresent(String.self, forKey: .alpha)
        
        min_temp = decodeIntFlexible(.min_temp)
        max_temp = decodeIntFlexible(.max_temp)
        bed_min_temp = decodeIntFlexible(.bed_min_temp)
        bed_max_temp = decodeIntFlexible(.bed_max_temp)
        weight = decodeDoubleFlexible(.weight)
        spoolweight = decodeDoubleFlexible(.spoolweight)
        density = decodeDoubleFlexible(.density)
        price = decodeDoubleFlexible(.price)
        diameter = decodeDoubleFlexible(.diameter)
        
        currency = try? c.decodeIfPresent(String.self, forKey: .currency)
        lot_nr = try? c.decodeIfPresent(String.self, forKey: .lot_nr)
    }
    
    init(id: Int? = nil,
         protocolName: String? = nil,
         version: String? = nil,
         brand: String? = nil,
         type: String? = nil,
         subtype: String? = nil,
         color_hex: String? = nil,
         additional_color_hexes: [String]? = nil,
         alpha: String? = nil,
         min_temp: Int? = nil,
         max_temp: Int? = nil,
         bed_min_temp: Int? = nil,
         bed_max_temp: Int? = nil,
         weight: Double? = nil,
         spoolweight: Double? = nil,
         density: Double? = nil,
         price: Double? = nil,
         currency: String? = nil,
         lot_nr: String? = nil,
         diameter: Double? = nil) {
        self.id = id
        self.protocolName = protocolName
        self.version = version
        self.brand = brand
        self.type = type
        self.subtype = subtype
        self.color_hex = color_hex
        self.additional_color_hexes = additional_color_hexes
        self.alpha = alpha
        self.min_temp = min_temp
        self.max_temp = max_temp
        self.bed_min_temp = bed_min_temp
        self.bed_max_temp = bed_max_temp
        self.weight = weight
        self.spoolweight = spoolweight
        self.density = density
        self.price = price
        self.currency = currency
        self.lot_nr = lot_nr
        self.diameter = diameter
    }
    
    static func == (lhs: OpenSpool, rhs: OpenSpool) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - NDEF helpers (single dict-based builder + reader)
func validateOpenSpool(_ dict: [String: Any]) throws {
    guard let proto = dict["protocol"] as? String, let _ = dict["version"] as? String else {
        throw OpenSpoolError.missingProtocolOrVersion
    }
    if proto.lowercased() != "openspool" {
        throw OpenSpoolError.protocolMismatch
    }
}

// Single, canonical builder: always include required keys and normalized values
func buildNdefMessageForOpenSpool(_ spool: OpenSpool) -> NFCNDEFMessage {
    var dict: [String: Any] = [:]
    dict["protocol"] = spool.protocolName ?? "openspool"
    dict["version"] = spool.version ?? "1.0"


    dict["brand"] = spool.brand ?? ""
    dict["type"] = spool.type ?? ""
    dict["subtype"] = spool.subtype ?? ""
    let color = (spool.color_hex ?? "").replacingOccurrences(of: "#", with: "")
    dict["color_hex"] = color
    dict["additional_color_hexes"] = spool.additional_color_hexes ?? []
    dict["alpha"] = spool.alpha ?? "FF"

    dict["min_temp"] = spool.min_temp ?? 0
    dict["max_temp"] = spool.max_temp ?? 0
    dict["bed_min_temp"] = spool.bed_min_temp ?? 0
    dict["bed_max_temp"] = spool.bed_max_temp ?? 0
    dict["weight"] = spool.weight ?? 0.0
    dict["spoolweight"] = spool.spoolweight ?? 0.0
    dict["density"] = spool.density ?? 0.0
    dict["price"] = spool.price ?? 0.0
    dict["currency"] = spool.currency ?? ""
    dict["lot_nr"] = spool.lot_nr ?? ""
    dict["diameter"] = spool.diameter ?? 0.0
    if let id = spool.id { dict["id"] = id }
    
    let data = (try? JSONSerialization.data(withJSONObject: dict, options: [])) ?? Data()
    print("WRITE JSON:", String(data: data, encoding: .utf8) ?? "<non-utf8>")
    
    let record = NFCNDEFPayload(format: .media,
        type: "application/json".data(using: .utf8) ?? Data(),
        identifier: Data(),
        payload: data)
    
    return NFCNDEFMessage(records: [record])
}
func openSpoolFromNdefMessage(_ message: NFCNDEFMessage) throws -> OpenSpool {
    for rec in message.records {
        let payloadData = rec.payload
        
        if let obj = try? JSONSerialization.jsonObject(with: payloadData, options: []),
           let dict = obj as? [String: Any] {
            print("READ DICT:", dict)
            try validateOpenSpool(dict)
            let jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let spool = try decoder.decode(OpenSpool.self, from: jsonData)
            return spool
        }
        
        if let s = String(data: payloadData, encoding: .utf8),
           let data2 = s.data(using: .utf8),
           let obj2 = try? JSONSerialization.jsonObject(with: data2, options: []),
           let dict2 = obj2 as? [String: Any] {
            print("READ DICT (fallback):", dict2)
            try validateOpenSpool(dict2)
            let jsonData = try JSONSerialization.data(withJSONObject: dict2, options: [])
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .useDefaultKeys
            let spool = try decoder.decode(OpenSpool.self, from: jsonData)
            return spool
        }
    }
    throw OpenSpoolError.invalidJSON
}

// MARK: - NFCNDEFMessage helper extension
extension NFCNDEFMessage {
    var approximatePayloadSize: Int {
        return records.reduce(0) { $0 + $1.payload.count + $1.type.count + 3 }
    }
}

// MARK: - ViewModel: handles NFC sessions
final class SpoolNFCViewModel: NSObject, ObservableObject {
    @Published var statusMessage: String = "Ready"
    @Published var selectedSpool: OpenSpool? = nil
    @Published var lastSpool: OpenSpool?
    @Published var isBusy: Bool = false
    @Published var pendingOpenSpool: OpenSpool? = nil
    @Published var price: Double?
    
    static let priceFormatter: NumberFormatter = {
        let nf = NumberFormatter()
        nf.numberStyle = .decimal
        nf.minimumFractionDigits = 2
        nf.maximumFractionDigits = 2
        return nf
    }()
    
    // pending message snapshot used by writer
    fileprivate var pendingNdefMessage: NFCNDEFMessage? = nil
    fileprivate var pendingWriteRequiredBytes: Int = 0
    var onCurrencyDetected: ((String) -> Void)?
    
    fileprivate var ndefSession: NFCNDEFReaderSession?
    fileprivate var tagSession: NFCTagReaderSession?
    fileprivate var pendingWriteText: String?
    
    enum WriterMode { case sample, text(String), clear }
    fileprivate var writerMode: WriterMode = .sample
    
    // Serial queue to guard pending snapshot (atomic)
    private let pendingQueue = DispatchQueue(label: "spool.pending.queue")
    
    override init() {
        self.statusMessage = "Ready"
        self.selectedSpool = nil
        self.lastSpool = nil
        self.pendingWriteText = nil
        self.ndefSession = nil
        self.tagSession = nil
        super.init()
    }
    
    // Called when a spool is detected by reader flow
    func handleDetectedSpool(_ spool: OpenSpool) {
        DispatchQueue.main.async {
            self.selectedSpool = spool
            self.lastSpool = spool
            self.statusMessage = "Spool gedetecteerd"
        }
    }
    
    func logSpoolFields(
        brand: String,
        filament: String,
        variantText: String?,
        hexColor: String?,
        additionalColors: [String],
        alpha: String?,
        minTemp: String,
        maxTemp: String,
        bedMinTemp: String,
        bedMaxTemp: String,
        gewicht: String,
        gewichtSpoel: String,
        dichtheid: String,
        prijs: String,
        currency: String,
        partijNr: String,
        diameter: String
    ) {
        print("""
        DBG OpenSpool —
        brand: \(brand)
        filament: \(filament)
        variantText: \(variantText ?? "")
        hexColor: \(hexColor ?? "")
        additionalColors: \(additionalColors)
        alpha: \(alpha ?? "")
        minTemp: \(minTemp)
        maxTemp: \(maxTemp)
        bedMinTemp: \(bedMinTemp)
        bedMaxTemp: \(bedMaxTemp)
        gewicht: \(gewicht)
        gewichtSpoel: \(gewichtSpoel)
        dichtheid: \(dichtheid)
        prijs: \(prijs)
        currency: \(currency)
        partijNr: \(partijNr)
        diameter: \(diameter)
        """)
    }
    
    
    // Helper parsers
    func intFromString(_ s: String) -> Int? {
        return Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    func doubleFromString(_ s: String) -> Double? {
        let normalized = s.replacingOccurrences(of: ",", with: ".").trimmingCharacters(in: .whitespacesAndNewlines)
        return Double(normalized)
    }
    
    // Build pendingNdefMessage from UI state values (call before startWriter)
    func preparePendingNdefMessageFromState(
        // Filament selection
        filament: String,
        customMaterial: String?,
        isOtherSelected: Bool,
        isSelected: Bool,
        // Variant
        variantText: String?,
        variantFocused: Bool?,
        // Color
        selectedColorName: String?,
        selectedColorColor: Color?,
        isColorSelected: Bool,
        showColorPickerOverlay: Bool?,
        customColor: String?,
        customColors: [String]?,
        hexColor: String?,
        colorNames: [String]?,
        // Brand
        brand: String,
        customBrand: String?,
        isOtherBrand: Bool,
        scannedBrand: String?,
        isBrandSelected: Bool,
        allBrands: [String]?,
        // SixFieldsTwoColumns
        gewicht: String,
        gewichtSpoel: String,
        dichtheid: String,
        diameter: String,
        prijs: String,
        partijNr: String,
        gewichtEdited: Bool,
        gewichtSpoelEdited: Bool,
        dichtheidEdited: Bool,
        diameterEdited: Bool,
        prijsEdited: Bool,
        partijNrEdited: Bool,
        currency: String?,
        storedCurrency: String?,
        // TemperatureBlock
        minTemp: String,
        maxTemp: String,
        bedMinTemp: String,
        bedMaxTemp: String,
        nozzleMinBorderColor: Color?,
        nozzleMaxBorderColor: Color?,
        bedMinBorderColor: Color?,
        bedMaxBorderColor: Color?
    ) {
        // Log raw UI values before any mapping (thread-safe snapshot)
        print("DBG UI raw before build:",
              "brand:'\(brand)'",
              "customBrand:'\(customBrand ?? "")'",
              "isOtherBrand:\(isOtherBrand)",
              "filament:'\(filament)'",
              "customMaterial:'\(customMaterial ?? "")'",
              "isOtherSelected:\(isOtherSelected)",
              "isSelected:\(isSelected)",
              "variantText:'\(variantText ?? "")'",
              "hexColor:'\(hexColor ?? "")'",
              "customColor:'\(customColor ?? "")'",
              "selectedColorName:'\(selectedColorName ?? "")'",
              "isColorSelected:\(isColorSelected)",
              "gewicht:'\(gewicht)'",
              "gewichtSpoel:'\(gewichtSpoel)'",
              "dichtheid:'\(dichtheid)'",
              "diameter:'\(diameter)'",
              "prijs:'\(prijs)'",
              "currency:'\(currency ?? storedCurrency ?? "")'",
              "partijNr:'\(partijNr)'",
              "minTemp:'\(minTemp)'",
              "maxTemp:'\(maxTemp)'",
              "bedMinTemp:'\(bedMinTemp)'",
              "bedMaxTemp:'\(bedMaxTemp)'"
        )
        
        // Resolve brand
        let resolvedBrand: String = {
            let trimmedCustom = customBrand?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if isOtherBrand && !trimmedCustom.isEmpty {
                return trimmedCustom
            }
            if isBrandSelected, let scanned = scannedBrand, !scanned.isEmpty {
                return scanned
            }
            let trimmed = brand.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Algemeen" : trimmed
        }()
        
        // Resolve filament/type
        let resolvedFilament: String = {
            let trimmedCustom = customMaterial?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            if isOtherSelected && !trimmedCustom.isEmpty { return trimmedCustom }
            let trimmed = filament.trimmingCharacters(in: .whitespacesAndNewlines)
            return trimmed.isEmpty ? "Unknown" : trimmed
        }()
        
        // Resolve subtype / variant
        let resolvedVariant: String = {
            let t = variantText?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            return t
        }()
        
        // Resolve color hex
        let resolvedHex: String = {
            let direct = (hexColor ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !direct.isEmpty { return direct.replacingOccurrences(of: "#", with: "") }
            let custom = (customColor ?? "").trimmingCharacters(in: .whitespacesAndNewlines)
            if !custom.isEmpty { return custom.replacingOccurrences(of: "#", with: "") }
            return ""
        }()
        
        // Additional colors
        let resolvedAdditionalColors: [String] = (customColors ?? []).filter { !$0.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        // Alpha default
        let resolvedAlpha = "FF"
        
        // Numeric fields
        let resolvedMinTemp = intFromString(minTemp) ?? 0
        let resolvedMaxTemp = intFromString(maxTemp) ?? 0
        let resolvedBedMinTemp = intFromString(bedMinTemp) ?? 0
        let resolvedBedMaxTemp = intFromString(bedMaxTemp) ?? 0
        
        let resolvedGewicht = doubleFromString(gewicht) ?? 0.0
        let resolvedGewichtSpoel = doubleFromString(gewichtSpoel) ?? 0.0
        let resolvedDichtheid = doubleFromString(dichtheid) ?? 0.0
        let resolvedPrijs = doubleFromString(prijs) ?? 0.0
        let resolvedDiameter = doubleFromString(diameter) ?? 0.0
        let resolvedPartijNr = partijNr.trimmingCharacters(in: .whitespacesAndNewlines)
        let resolvedCurrency = (currency?.isEmpty ?? true) ? (storedCurrency ?? "") : (currency ?? storedCurrency ?? "")
        
        // Log mapped values that will be passed into OpenSpool initializer
        print("DBG mapped values (to initializer):",
              "brand:'\(resolvedBrand)'",
              "type:'\(resolvedFilament)'",
              "subtype:'\(resolvedVariant)'",
              "color_hex:'\(resolvedHex)'",
              "additional_color_hexes:\(resolvedAdditionalColors)",
              "alpha:\(resolvedAlpha)",
              "min_temp:\(resolvedMinTemp)",
              "max_temp:\(resolvedMaxTemp)",
              "bed_min_temp:\(resolvedBedMinTemp)",
              "bed_max_temp:\(resolvedBedMaxTemp)",
              "weight:\(resolvedGewicht)",
              "spoolweight:\(resolvedGewichtSpoel)",
              "density:\(resolvedDichtheid)",
              "price:\(resolvedPrijs)",
              "currency:'\(resolvedCurrency)'",
              "lot_nr:'\(resolvedPartijNr)'",
              "diameter:\(resolvedDiameter)"
        )
        
        // Build exactly one OpenSpool via initializer (no mutation)
        let spool = OpenSpool(
            id: nil,
            protocolName: "openspool",
            version: "1.0",
            brand: resolvedBrand,
            type: resolvedFilament,
            subtype: resolvedVariant,
            color_hex: resolvedHex,
            additional_color_hexes: resolvedAdditionalColors,
            alpha: resolvedAlpha,
            min_temp: resolvedMinTemp,
            max_temp: resolvedMaxTemp,
            bed_min_temp: resolvedBedMinTemp,
            bed_max_temp: resolvedBedMaxTemp,
            weight: resolvedGewicht,
            spoolweight: resolvedGewichtSpoel,
            density: resolvedDichtheid,
            price: resolvedPrijs,
            currency: resolvedCurrency.isEmpty ? nil : resolvedCurrency,
            lot_nr: resolvedPartijNr.isEmpty ? nil : resolvedPartijNr,
            diameter: resolvedDiameter
        )
        
        // Log all fields right after building
        logSpoolFields(
            brand: spool.brand ?? "",
            filament: spool.type ?? "",
            variantText: spool.subtype,
            hexColor: spool.color_hex,
            additionalColors: spool.additional_color_hexes ?? [],
            alpha: spool.alpha,
            minTemp: String(spool.min_temp ?? 0),
            maxTemp: String(spool.max_temp ?? 0),
            bedMinTemp: String(spool.bed_min_temp ?? 0),
            bedMaxTemp: String(spool.bed_max_temp ?? 0),
            gewicht: String(spool.weight ?? 0.0),
            gewichtSpoel: String(spool.spoolweight ?? 0.0),
            dichtheid: String(spool.density ?? 0.0),
            prijs: String(spool.price ?? 0.0),
            currency: spool.currency ?? "",
            partijNr: spool.lot_nr ?? "",
            diameter: String(spool.diameter ?? 0.0)
        )
        
        // Build pending NDEF and store a stable snapshot for writer; do this synchronously to ensure ordering
        let msg = buildNdefMessageForOpenSpool(spool)
        pendingQueue.sync {
            self.pendingNdefMessage = msg
            self.pendingWriteRequiredBytes = msg.approximatePayloadSize
            self.pendingOpenSpool = spool
        }
    }
    
    // MARK: Reader
    func startReader() {
        guard NFCNDEFReaderSession.readingAvailable else {
            DispatchQueue.main.async { self.statusMessage = NSLocalizedString("NFC.reading.this.device", comment: "NFC Reading warning for Device") }
            return
        }
        ndefSession = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: false)
        ndefSession?.alertMessage = NSLocalizedString("hold.close.tag", comment: "Hold phone close")
        ndefSession?.begin()
        DispatchQueue.main.async { self.statusMessage = NSLocalizedString("reader.started.waiting", comment: "Reader Started and waiting") }
        print(NSLocalizedString("reader.started", comment: "Reader Started"))
    }
    
    // Use the formatter when updating or producing a formatted string
    func formattedPrice() -> String {
        guard let p = price else { return "—" }
        return Self.priceFormatter.string(from: NSNumber(value: p)) ?? String(format: "%.2f", p)
    }
    
    // When parsing tag data, set price on main thread:
    func handleParsedPrice(_ parsed: Double?) {
        DispatchQueue.main.async { self.price = parsed }
    }
    
    // MARK: Writer helpers
    func performWrite(openSpool: OpenSpool, to ndefTag: NFCNDEFTag, session: NFCTagReaderSession) {
        if let json = try? JSONEncoder().encode(openSpool),
           let s = String(data: json, encoding: .utf8) {
            print("NFC WRITE - OpenSpool JSON:\n\(s)")
        } else {
            print("NFC WRITE - Failed to encode OpenSpool")
        }
        
        let pending = buildNdefMessageForOpenSpool(openSpool)
        pendingQueue.sync {
            self.pendingNdefMessage = pending
            self.pendingWriteRequiredBytes = pending.approximatePayloadSize
        }
        if let payload = pending.records.first?.payload,
           let payloadStr = String(data: payload, encoding: .utf8) {
            print("NFC WRITE - NDEF payload (first record):\n\(payloadStr)")
            print("NFC WRITE - pendingWriteRequiredBytes:", self.pendingWriteRequiredBytes)
        } else {
            print("NFC WRITE - NDEF payload is empty or non-utf8")
        }
        writePendingNdefMessage(to: ndefTag, session: session)
    }
    
    func beginWriteSession() {
        self.writerMode = .sample
        self.tagSession = NFCTagReaderSession(pollingOption: .iso14443, delegate: self, queue: nil)
        self.tagSession?.alertMessage = NSLocalizedString("hold.near.tag.write", comment: "Hold Phone Close to Tag and Write")
        self.tagSession?.begin()
    }
    
    func startWriter(mode: WriterMode = .sample) {
        switch mode {
        case .sample: pendingWriteText = nil
        case .text(let s): pendingWriteText = s
        case .clear: pendingWriteText = nil
        }
        writerMode = mode
        guard NFCTagReaderSession.readingAvailable else {
            DispatchQueue.main.async { self.statusMessage = "NFC tag sessions not available." }
            return
        }
        guard self.tagSession == nil && self.ndefSession == nil else {
            DispatchQueue.main.async { self.statusMessage = "NFC session already active." }
            return
        }
        
        // Prepare message snapshot (use selectedSpool/lastSpool fallback)
        let spoolToWrite = selectedSpool ?? lastSpool ?? OpenSpool(id: nil, protocolName: "openspool", version: "1.0", brand: "Generic")
        let msg = buildNdefMessageForOpenSpool(spoolToWrite)
        pendingQueue.sync {
            self.pendingNdefMessage = msg
            self.pendingWriteRequiredBytes = msg.approximatePayloadSize
        }
        
        self.ndefSession?.invalidate()
        self.ndefSession = nil
        self.tagSession?.invalidate()
        self.tagSession = nil
        
        let alertText: String = {
            switch writerMode {
            case .sample: return NSLocalizedString("hold.close", comment: "Hold Phone Close")
            case .text: return NSLocalizedString("hold.near.tag", comment: "Hold Phone Close to Tag")
            case .clear: return NSLocalizedString("hold.close.clear", comment: "Hold Phone Close to Clear Tag")
            }
        }()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.tagSession = NFCTagReaderSession(pollingOption: [.iso14443, .iso15693], delegate: self)
            self.tagSession?.alertMessage = alertText
            self.tagSession?.begin()
        }
        DispatchQueue.main.async { self.statusMessage = NSLocalizedString("write.start.waiting", comment: "Writer started and waiting") }
        print("Writer started (mode: \(writerMode))")
    }
    
    func invalidateSessions() {
        ndefSession?.invalidate()
        ndefSession = nil
        tagSession?.invalidate()
        tagSession = nil
    }
    
    // MARK: - JSON write helper: writes prepared pendingNdefMessage (application/json)
    func writePendingNdefMessage(to tag: NFCNDEFTag, session: NFCTagReaderSession) {
        var snapshotMessage: NFCNDEFMessage?
        pendingQueue.sync {
            snapshotMessage = self.pendingNdefMessage
        }
        guard let message = snapshotMessage else {
            session.invalidate(errorMessage: "No NDEF message prepared.")
            DispatchQueue.main.async { self.statusMessage = "No message to write." }
            print("DBG writePendingNdefMessage: no pendingNdefMessage")
            return
        }
        
        if let first = message.records.first {
            print("DBG writePendingNdefMessage - pending payload (pre-query):", String(data: first.payload, encoding: .utf8) ?? "<non-utf8>")
        } else {
            print("DBG writePendingNdefMessage - pending message has no records")
        }
        
        tag.queryNDEFStatus { status, capacity, qErr in
            if let qErr = qErr {
                session.invalidate(errorMessage: "Query NDEF failed: \(qErr.localizedDescription)")
                DispatchQueue.main.async { self.statusMessage = "Query NDEF failed: \(qErr.localizedDescription)" }
                print("DBG writePendingNdefMessage - query error:", qErr)
                return
            }
            
            if status == .notSupported {
                session.invalidate(errorMessage: "Tag does not support NDEF.")
                DispatchQueue.main.async { self.statusMessage = "Tag not NDEF" }
                print("DBG writePendingNdefMessage - tag not NDEF")
                return
            }
            
            var currentMessage: NFCNDEFMessage?
            self.pendingQueue.sync {
                currentMessage = self.pendingNdefMessage
            }
            guard let finalMessage = currentMessage else {
                session.invalidate(errorMessage: "Pending message lost before write.")
                DispatchQueue.main.async { self.statusMessage = "Pending message lost" }
                print("DBG writePendingNdefMessage - pending message became nil before write")
                return
            }
            
            let size = finalMessage.approximatePayloadSize
            print("DBG writePendingNdefMessage - message size: \(size), tag capacity: \(capacity)")
            
            if size > capacity {
                session.invalidate(errorMessage: "Data too large for tag (capacity: \(capacity) bytes). Need \(size) bytes.")
                DispatchQueue.main.async { self.statusMessage = "Data too large for tag" }
                print("DBG writePendingNdefMessage - data too large")
                return
            }
            
            if let finalFirst = finalMessage.records.first {
                print("DBG writePendingNdefMessage - final payload (before write):", String(data: finalFirst.payload, encoding: .utf8) ?? "<non-utf8>")
            } else {
                print("DBG writePendingNdefMessage - final message has no records")
            }
            
            tag.writeNDEF(finalMessage) { writeError in
                if let writeError = writeError {
                    session.invalidate(errorMessage: "Write failed: \(writeError.localizedDescription)")
                    DispatchQueue.main.async { self.statusMessage = "Write failed: \(writeError.localizedDescription)" }
                    print("DBG writePendingNdefMessage - write failed:", writeError)
                } else {
                    session.alertMessage = NSLocalizedString("write.succes", comment: "Write Successfull")
                    session.invalidate()
                    DispatchQueue.main.async { self.statusMessage = "Wrote OpenSpool JSON" }
                    print("DBG writePendingNdefMessage - wrote OpenSpool JSON")
                    self.pendingQueue.sync {
                        self.pendingNdefMessage = nil
                    }
                }
            }
        }
    }
    
    // Clear tag by writing an empty NDEF message
    func clearTag(_ tag: NFCNDEFTag, session: NFCTagReaderSession) {
        let emptyMessage = NFCNDEFMessage(records: [])
        tag.queryNDEFStatus { status, capacity, error in
            if let error = error {
                session.invalidate(errorMessage: String(format: NSLocalizedString("query.failed", comment: "Failed query NDEF with error"), String(describing: error.localizedDescription)))
                DispatchQueue.main.async { self.statusMessage =  String(format: NSLocalizedString("query.ndef.failed", comment: "FQuery NDEF failed with error"), String(describing: error.localizedDescription)) }
                return
            }
            if status == .notSupported {
                session.invalidate(errorMessage: NSLocalizedString("tag.no.support", comment: "Tag is no NDEF"))
                DispatchQueue.main.async { self.statusMessage = NSLocalizedString("tag.noNDEF", comment: "Tag is no NDEF") }
                return
            }
            tag.writeNDEF(emptyMessage) { writeError in
                if let writeError = writeError {
                    session.invalidate(errorMessage: String(format: NSLocalizedString("erase.failed.format", comment: "Erase failed with error"), String(describing: writeError.localizedDescription)))
                    DispatchQueue.main.async { self.statusMessage = String(format: NSLocalizedString("erase.failed", comment: ""), writeError.localizedDescription) }
                    print(String(format: NSLocalizedString("erase.failed.log", comment: "Erase failed with error"), String(describing: writeError)))
                } else {
                    session.alertMessage = NSLocalizedString("tag.cleared", comment: "Tag Cleared")
                    session.invalidate()
                    DispatchQueue.main.async { self.statusMessage = NSLocalizedString("tag.cleared.succes", comment: "Tag succesfully Cleared") }
                    print(NSLocalizedString("tag.cleared.success", comment: "Tag succesfully Cleared"))
                }
            }
        }
    }
}

// MARK: - NFCTagReaderSessionDelegate (writer flow)
extension SpoolNFCViewModel: NFCTagReaderSessionDelegate {
    func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        DispatchQueue.main.async {
            self.statusMessage = "Tag session active; present a tag."
        }
        print("Tag session active")
    }
    
    
    func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.statusMessage = "Tag session invalidated: \(error.localizedDescription)"
            self.tagSession = nil
        }
        print("Tag session invalidated: \(error)")
    }
    
    func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let firstTag = tags.first else {
            session.invalidate(errorMessage: "No tag found")
            return
        }
        
        func ndefTag(from tag: NFCTag) -> NFCNDEFTag? {
            switch tag {
            case .miFare(let t):   return t
            case .iso15693(let t): return t
            case .iso7816(let t):  return t
            case .feliCa(let t):   return t
            @unknown default:      return nil
            }
        }
        
        func connect(retries: Int = 3, completion: @escaping (NFCNDEFTag?) -> Void) {
            session.connect(to: firstTag) { err in
                if let err = err {
                    if retries > 1 {
                        DispatchQueue.global().asyncAfter(deadline: .now() + 0.15) {
                            connect(retries: retries - 1, completion: completion)
                        }
                    } else {
                        session.invalidate(errorMessage: "Connection failed: \(err.localizedDescription)")
                        print("Connection failed: \(err)")
                        completion(nil)
                    }
                    return
                }
                guard let ndef = ndefTag(from: firstTag) else {
                    session.invalidate(errorMessage: "Unsupported tag type")
                    print("Unsupported tag type")
                    completion(nil)
                    return
                }
                completion(ndef)
            }
        }
        
        func writeMessage(_ message: NFCNDEFMessage, to tag: NFCNDEFTag, retries: Int = 2, completion: @escaping (Error?) -> Void) {
            tag.queryNDEFStatus { status, capacity, qErr in
                if let qErr = qErr { completion(qErr); return }
                
                switch status {
                case .notSupported:
                    let e = NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Tag does not support NDEF."])
                    completion(e)
                case .readOnly:
                    let e = NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Tag is read-only."])
                    completion(e)
                case .readWrite:
                    print("DBG about to buildNdefMessage — selectedSpool raw:", self.selectedSpool as Any)
                    let spoolToWrite = self.selectedSpool ?? self.lastSpool ?? OpenSpool(id: nil, protocolName: "openspool", version: "1.0", brand: "Generic")
                    let msgToWrite: NFCNDEFMessage
                    var snapshot: NFCNDEFMessage?
                    self.pendingQueue.sync { snapshot = self.pendingNdefMessage }
                    if let pending = snapshot {
                        msgToWrite = pending
                    } else {
                        msgToWrite = buildNdefMessageForOpenSpool(spoolToWrite)
                    }
                    self.pendingQueue.sync {
                        self.pendingNdefMessage = msgToWrite
                        self.pendingWriteRequiredBytes = msgToWrite.approximatePayloadSize
                    }
                    let size = msgToWrite.approximatePayloadSize
                    print("DBG built JSON payload:", String(data: msgToWrite.records.first?.payload ?? Data(), encoding: .utf8) ?? "")
                    print("About to write payload size: \(size), capacity: \(capacity)")
                    for (i, record) in msgToWrite.records.enumerated() {
                        if let t = String(data: record.payload, encoding: .utf8) {
                            print("Record[\(i)] payload utf8:", t)
                        } else {
                            print("Record[\(i)] payload bytes:", record.payload as NSData)
                        }
                    }
                    if size > capacity {
                        let err = NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Data too large for tag (capacity: \(capacity) bytes). Need \(size) bytes."])
                        completion(err); return
                    }
                    
                    func performWrite(_ remainingRetries: Int) {
                        tag.writeNDEF(msgToWrite) { wErr in
                            if let wErr = wErr {
                                if remainingRetries > 0 {
                                    DispatchQueue.global().asyncAfter(deadline: .now() + 0.3) { [weak self] in
                                        guard let _ = self else { completion(wErr); return }
                                        performWrite(remainingRetries - 1)
                                    }
                                } else {
                                    completion(wErr)
                                }
                            } else {
                                completion(nil)
                            }
                        }
                    }
                    
                    performWrite(retries)
                @unknown default:
                    let e = NSError(domain: "NFC", code: 0, userInfo: [NSLocalizedDescriptionKey: "Unknown NDEF status"])
                    completion(e)
                }
            }
        }
        
        connect { [weak self] ndef in
        guard let self = self else { return }
        guard let ndefTag = ndef else { return }


        // Optional read for debug
        ndefTag.readNDEF { existing, readErr in
            if let readErr = readErr {
                print("readNDEF error: \(readErr)")
            } else if let existing = existing {
                print("Existing NDEF with \(existing.records.count) records")
                for (i, r) in existing.records.enumerated() {
                    if let s = String(data: r.payload, encoding: .utf8) {
                        print("Existing Record[ \(i)] utf8:", s)
                    } else {
                        print("Existing Record[ \(i)] bytes:", r.payload as NSData)
                    }
                }
            }

            // perform requested writer action
            switch self.writerMode {
            case .sample:
                var pendingSnapshot: OpenSpool?
                self.pendingQueue.sync { pendingSnapshot = self.pendingOpenSpool }
                if let pending = pendingSnapshot {
                    self.logSpoolFields(
                        brand: pending.brand ?? "",
                        filament: pending.type ?? "",
                        variantText: pending.subtype,
                        hexColor: pending.color_hex,
                        additionalColors: pending.additional_color_hexes ?? [],
                        alpha: pending.alpha,
                        minTemp: String(pending.min_temp ?? 0),
                        maxTemp: String(pending.max_temp ?? 0),
                        bedMinTemp: String(pending.bed_min_temp ?? 0),
                        bedMaxTemp: String(pending.bed_max_temp ?? 0),
                        gewicht: String(pending.weight ?? 0.0),
                        gewichtSpoel: String(pending.spoolweight ?? 0.0),
                        dichtheid: String(pending.density ?? 0.0),
                        prijs: String(pending.price ?? 0.0),
                        currency: pending.currency ?? "",
                        partijNr: pending.lot_nr ?? "",
                        diameter: String(pending.diameter ?? 0.0)
                    )

                    // Debug JSON — encode on main to avoid actor/isolation issues
                    DispatchQueue.main.async {
                        let json = (try? JSONEncoder().encode(pending)).flatMap { String(data: $0, encoding: .utf8) } ?? ""
                        print("DBG pendingOpenSpool JSON before write:", json)
                    }

                    // perform write directly (do not hop to global queue) to keep NFC stack happy
                    self.performWrite(openSpool: pending, to: ndefTag, session: session)

                    // clear pending on main after initiating write (or after write callback)
                    DispatchQueue.main.async {
                        self.pendingOpenSpool = nil
                    }
                    return
                }

                // fallback if no pendingOpenSpool: read published state on main, then write
                var fallbackSpool: OpenSpool!
                DispatchQueue.main.sync {
                    fallbackSpool = self.selectedSpool ?? self.lastSpool ?? OpenSpool(id: nil, protocolName: "openspool", version: "1.0", brand: "Generic")
                }
                print("DBG: writerMode .sample — no pendingOpenSpool; falling back to fallbackSpool:")

                // call performWrite directly so writeNDEF is executed on same callstack as readNDEF callback
                self.performWrite(openSpool: fallbackSpool, to: ndefTag, session: session)

            case .clear:
                print("DBG: writerMode .clear — clearing tag")
                // ensure clearTag's UI-affecting mutations run on main
                DispatchQueue.main.async {
                    self.clearTag(ndefTag, session: session)
                }

            default:
                print("DBG: unsupported writerMode:", self.writerMode)
                session.invalidate(errorMessage: "Unsupported writer mode")
                return
                }
            }
        }
    }
}
                
           
    

// MARK: - NFCNDEFReaderSessionDelegate (reader flow)
extension SpoolNFCViewModel: NFCNDEFReaderSessionDelegate {
    func readerSessionDidBecomeActive(_ session: NFCNDEFReaderSession) {
        DispatchQueue.main.async {
            self.statusMessage = "Reader active; present a tag."
        }
        print("Reader active")
    }
    
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        DispatchQueue.main.async {
            self.statusMessage = "Reader session invalidated: \(error.localizedDescription)"
            self.ndefSession = nil
        }
        print("Reader session invalidated: \(error)")
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        DispatchQueue.global(qos: .userInitiated).async {
            for message in messages {
                for rec in message.records {
                    print("record TNF: \(rec.typeNameFormat)")
                    print("record type (utf8):", String(data: rec.type, encoding: .utf8) ?? "")
                    print("payload utf8:", String(data: rec.payload, encoding: .utf8) ?? "")
                    print("payload hex:", rec.payload.map { String(format: "%02x", $0) }.joined())
                    if let jsonString = String(data: rec.payload, encoding: .utf8) {
                        print("decoded jsonString:", jsonString)
                        do {
                            _ = try JSONSerialization.jsonObject(with: Data(jsonString.utf8))
                            print(NSLocalizedString("json.valid", comment: "Debug: json valid"))
                        } catch {
                            print(NSLocalizedString("json.parse.error", comment: "Debug: json prse error"), error)
                        }
                    } else {
                        print(NSLocalizedString("payload.not.valid", comment: "Debug: Payload not valid UTF-8"))
                    }
                }
                
                do {
                    let spool = try openSpoolFromNdefMessage(message)
                    DispatchQueue.main.async {
                        self.lastSpool = spool
                        self.selectedSpool = spool
                        
                        let pendingMsg = buildNdefMessageForOpenSpool(spool)
                        self.pendingQueue.sync {
                            self.pendingNdefMessage = pendingMsg
                            self.pendingWriteRequiredBytes = pendingMsg.approximatePayloadSize
                            self.pendingOpenSpool = spool
                        }
                        
                        self.statusMessage = NSLocalizedString("spool.detected", comment: "Debug: Spool Detected")
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                            self.ndefSession?.invalidate()
                            self.ndefSession = nil
                        }
                        
                        print(NSLocalizedString("assigned.pending. lastpool", comment: "Debug: readNDEF completion"), spool)
                        print(NSLocalizedString("dbg.readNDEF.completion", comment: "Debug: readNDEF completion"), message as Any)
                        print(NSLocalizedString("dbg.readNDEF.completion", comment: "Debug: readNDEF completion"), message as Any)
                    }
                } catch {
                    DispatchQueue.main.async {
                        self.statusMessage = String(format: NSLocalizedString("failed.parse.openspool", comment: "Failed to parse OpenSpool with error"), String(describing: error.localizedDescription))
                    }
                    print(String(format: NSLocalizedString("failed.parse.ndef.format", comment: "Failed to parse NDEF message with error"), String(describing: error)))
                    print(NSLocalizedString("dbg.readNDEF.completion", comment: "Debug: readNDEF completion"), message as Any)
                    print(NSLocalizedString("dbg.readNDEF.completion", comment: "Debug: readNDEF completion"), message as Any)
                }
            }
        }
    }
}
