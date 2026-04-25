import SwiftUI
import Combine

// MARK: - NFC assumptions
// NFCReader and NFCWriter are ObservableObject types with these members used here:
// - NFCReader: @Published var lastMessage: String?; func startScanning()
// - NFCWriter: @Published var lastMessage: String?; func write(text: String)
// These types must exist elsewhere in the project.
extension View {
    func simplePlaceholder(_ text: String, when shouldShow: Bool, alignment: Alignment = .leading) -> some View {
        ZStack(alignment: alignment) {
            if shouldShow {
                Text(text)
                    .foregroundColor(.gray)
                    .padding(.horizontal, 12)
            }
            self
        }
    }
}

private let defaultSpoolmanURL = ""
       
struct ContentView: View {
    // App state
    @AppStorage("didInitializeDefaults") private var didInitializeDefaults: Bool = false
    @AppStorage("spoolmanURL") private var urlText: String = defaultSpoolmanURL
    @AppStorage("spoolmanURL") private var spoolmanIP: String = ""
    //@AppStorage("spoolmanURL") private var storedSpoolmanURL: String = ""
    // Voor Strings
    //@AppStorage("spoolmanURL") private var spoolmanURL: String = ""
    @AppStorage("brand") private var storedBrand = NSLocalizedString("storedBrand.title", comment: "storedBrand title") { didSet { brand = storedBrand } }
    @AppStorage("customBrand") private var storedCustomBrand: String = ""
    @AppStorage("filament") private var storedFilament: String = "PLA"
    @AppStorage("isSelected") private var storedIsSelected = false
    @AppStorage("customMaterial") private var storedCustomMaterial: String = ""
    @AppStorage("variantText") private var storedVariantText: String = ""
    
    // Voor Booleans
    @AppStorage("isOtherBrand") private var storedIsOtherBrand: Bool = false
    @AppStorage("isBrandSelected") private var storedIsBrandSelected = false
    @AppStorage("isOtherSelected") private var storedIsOtherSelected: Bool = false
    @AppStorage("isColorSelected") private var storedIsColorSelected: Bool = false
    
    // Voor Ints of optionele Ints
    @AppStorage("selectedFilamentID") private var storedSelectedFilamentID: Int = -1
    // gebruik -1 als 'nil' sentinel; of bewaar optioneel via JSON in String.
    @AppStorage("selectedColorName") private var storedSelectedColorName = NSLocalizedString("storedSelectedColorName.default", comment: "default Color Name")
    //@AppStorage("selectedColorColor") private var storedSelectedColorColor = Color(.white)
    
    // Voor kleuren (Color is niet direct ondersteund) — bewaar hex-string
    @AppStorage("selectedColorHex") private var storedSelectedColorHex: String = "#FFFFFF"
    @AppStorage("customColor") private var storedCustomColor: Bool = false
    private var selectedColor: Color { Color(hex: storedSelectedColorHex) } // zie helper
    
    // Voor numerieke waarden die je als String gebruikt in jouw UI:
    @AppStorage("gewicht") private var storedGewicht: String = ""
    @AppStorage("gewichtEdited") private var storedGewichtEdited = false
    @AppStorage("gewichtSpoel") private var storedGewichtSpoel: String = ""
    @AppStorage("gewichtSpoelEdited") private var storedGewichtSpoelEdited = false
    @AppStorage("dichtheid") private var storedDichtheid: String = ""
    @AppStorage("dichtheidEdited") private var storedDichtheidEdited = false
    @AppStorage("diameter") private var storedDiameter: String = ""
    @AppStorage("diameterEdited") private var storedDiameterEdited = false
    @AppStorage("prijs") private var storedPrijs: String = ""
    @AppStorage("prijsEdited") private var storedPrijsEdited = false
    @AppStorage("currency") private var storedCurrency: String = ""
    @AppStorage("currencyEdited") private var storedCurrencyEdited = ""
    @AppStorage("partijNr") private var storedPartijNr: String = ""
    @AppStorage("partijNrEdited") private var storedPartijNrEdited = false
    @AppStorage("storedEdited") private var storedEdited: String = ""
    @AppStorage("storedEditedEdited") private var storedEditedEdited = false
    
    // Temperatuur-velden
    @AppStorage("minTemp") private var storedMinTemp: String = "190"
    @AppStorage("maxTemp") private var storedMaxTemp: String = "250"
    @AppStorage("bedMinTemp") private var storedBedMinTemp: String = "50"
    @AppStorage("bedMaxTemp") private var storedBedMaxTemp: String = "100"
    
    // Voor flags over eerste-initialisatie
    @Environment(\.dismiss) var dismiss
    @State private var showSettings = false
    
    //Spoolman
    @State private var selectedFilamentID: Int?
    @State private var isSelectedVisual: Bool = false
    
    
    
    
    //Brand
    @State private var brand = NSLocalizedString("Brand.title", comment: "Brand title")
    @State private var customBrand: String = ""
    @State private var isOtherBrand: Bool = false
    @State private var isBrandSelected: Bool = false
    
    // Filament / variant
    @State private var isSelected: Bool = false
    @State private var filament: String = "PLA"
    @State private var isOtherSelected: Bool = false
    @State private var customMaterial: String = ""
    @State private var variantText: String = ""
    @FocusState private var variantFocused: Bool
    
    // Color
    @State private var selectedColorName: String = NSLocalizedString("selectedColorName.default", comment: "default Color Name")
    @State private var selectedColorColor: Color = .white
    @State private var isColorSelected: Bool = false
    @State private var showColorPickerOverlay = false
    @State private var customColor: Color = .white
    @State private var customColors: [String] = []
    @State private var hexColor = "#FFFFFF"
    
    //SixFieldsTwoColumns
    @State private var gewicht = ""
    @State private var gewichtSpoel = ""
    @State private var dichtheid = ""
    @State private var diameter = ""
    @State private var prijs = ""
    @State private var currency: String = "€"
    @State private var partijNr = ""
    
    @State private var gewichtEdited = false
    @State private var gewichtSpoelEdited = false
    @State private var dichtheidEdited = false
    @State private var diameterEdited = false
    @State private var prijsEdited = false
    @State private var partijNrEdited = false
    //@State private var showingInfoAlert = false
    
    
    // Temps & borders
    @State private var minTemp = "190"
    @State private var maxTemp = "250"
    @State private var bedMinTemp = "50"
    @State private var bedMaxTemp = "100"
    @State private var refreshToggle = false
    
    @State private var nozzleMinBorderColor: Color = .gray
    @State private var nozzleMaxBorderColor: Color = .gray
    @State private var bedMinBorderColor: Color = .gray
    @State private var bedMaxBorderColor: Color = .gray
    
    // NFC
    @State private var textToWrite: String = ""
    @StateObject private var reader = SpoolNFCViewModel()
    @State private var selectedSpool: OpenSpool? = nil
    @State private var scannedBrand: String = ""
    @State private var isResetting = false
    
    
    
    
    // Constants
    private let allFilaments = ["PLA", "PETG", "ABS", "TPU", "ASA", "Nylon", "PC", "PET", NSLocalizedString("filament", comment: "Text for other")]
    private let colorNameKeys = ["color.white","color.black","color.red","color.blue","color.green",
                                 "color.yellow","color.gray","color.orange","color.purple","color.pink"
    ]
    
    private let allBrands = [NSLocalizedString("isOtherBrand", comment: "Text for other"),NSLocalizedString("isBrandSelected", comment: "Text for generic"),"Artillery","3DHoJor","Bambu Lab","Elegoo","Eryone","eSun","GEEETECH","JAYO","Kingroon","Polymaker","Snapmaker","SUNLU","TECBEARS"]
    
    private var colorNames: [String] {
        colorNameKeys.map { NSLocalizedString($0, comment: "") }
    }
    
    @State private var showingResetConfirm = false
    
    func syncFromModel() {
        guard let spool = reader.lastSpool else {
            gewicht = ""; gewichtSpoel = ""; dichtheid = ""; diameter = ""; prijs = ""; partijNr = ""
            return
        }
        
        dichtheid = spool.density.map { String(format: "%.2f", $0) } ?? ""
    }
    
    func commitFieldsToModel() {
        func toDouble(_ s: String) -> Double? {
            let cleaned = s.replacingOccurrences(of: ",", with: ".")
            return Double(cleaned)
        }
        
        
        guard var s = reader.lastSpool else { return }
        
        if let v = toDouble(dichtheid) { s.density = v }
        
        reader.lastSpool = s
        
        // reformat fields to normalized display
        syncFromModel()
    }

    
    
    func currencySymbol(from codeOrSymbol: String?) -> String {
        guard let s = codeOrSymbol?.trimmingCharacters(in: .whitespacesAndNewlines), !s.isEmpty else { return "" }
        switch s.uppercased() {
        case "EUR", "EURO", "€": return "€"
        case "USD", "DOLLAR", "$": return "$"
        case "GBP", "POUND", "£": return "£"
        default:
            // als het al een symbool is of ongewone code, toon direct
            return s
        }
    }
    private func restoreDefaults() {
        DispatchQueue.main.async {
            
            // Persistente defaults (@AppStorage)
            didInitializeDefaults = true
            // NIET spoolmanURL resetten als je dat wilt bewaren
            // urlText = "" // verwijder indien niet gewenst
            
            storedBrand = NSLocalizedString("storedBrand.title", comment: "storedBrand title")
            storedCustomBrand = ""
            storedFilament = "PLA"
            storedIsSelected = false
            storedCustomMaterial = ""
            storedVariantText = ""
            
            storedIsOtherBrand = false
            storedIsOtherSelected = false
            storedIsBrandSelected = false
            storedIsColorSelected = false
            
            storedSelectedFilamentID = -1
            storedSelectedColorHex = "#FFFFFF"
            storedSelectedColorName = NSLocalizedString("storedColorName.default", comment: "default Color Name")
            storedSelectedColorHex = "#FFFFFF"
            storedCustomColor = false
            
            storedGewicht = ""
            storedGewichtSpoel = ""
            storedDichtheid = ""
            storedDiameter = ""
            storedPrijs = ""
            storedPartijNr = ""
            gewichtSpoel = ""
            dichtheid = ""
            prijs = ""
            partijNr = ""
            customColor = Color.white
            
            storedMinTemp = "190"
            storedMaxTemp = "250"
            storedBedMinTemp = "50"
            storedBedMaxTemp = "100"
            
            // UI state resets (@State vars)
            selectedFilamentID = nil           // als je zo'n @State hebt
            selectedColorName = NSLocalizedString("selectedColorName.default", comment: "default Color Name")
            selectedColorColor = .white
            isColorSelected = false
            isOtherBrand = false
            isOtherSelected = false
            
            gewichtEdited = false
            gewichtSpoelEdited = false
            dichtheidEdited = false
            diameterEdited = false
            prijsEdited = false
            partijNrEdited = false
            
            // Border kleuren (UI)
            nozzleMinBorderColor = .gray
            nozzleMaxBorderColor = .gray
            bedMinBorderColor = .gray
            bedMaxBorderColor = .gray
            
            filament = "PLA"
            isSelected = false
            scannedBrand = ""
            variantText = ""
            
            reader.lastSpool = nil
            selectedSpool = nil
            
            
            // FORCE clear weight and diameter - no conditions
            self.gewicht = ""
            self.diameter = ""
            self.storedGewicht = ""
            self.storedDiameter = ""
            
            // FORCE set edited flags to false
            self.gewichtEdited = false
            self.diameterEdited = false
            self.storedGewichtEdited = false
            self.storedDiameterEdited = false
                    
        }
        print("restoreDefaults start")
        storedPrijs = ""
        prijs = ""
        storedGewichtSpoel = ""
        gewichtSpoel = ""
        storedDichtheid = ""
        dichtheid = ""
        storedPartijNr = ""
        partijNr = ""
        storedFilament = "PLA"
        filament = "PLA"
        storedIsSelected = false
        isSelected = false
        storedIsColorSelected = false
        isColorSelected = false
        storedSelectedColorName = NSLocalizedString("storedSelectedColorName.default", comment: "default Color Name")
        selectedColorName = NSLocalizedString("selectedColorName.default", comment: "default Color Name")
        storedSelectedColorHex = "#FFFFFF"
        selectedColorColor = .white
        storedIsColorSelected = false
        storedBrand = NSLocalizedString("storedBrand.title", comment: "storedBrand title")
        brand = NSLocalizedString("Brand.title", comment: "Brand title")
        storedIsOtherSelected = false
        isOtherSelected = false
        storedIsColorSelected = false
        isColorSelected = false
        storedCustomColor = false
        customColor = Color.white
        storedIsBrandSelected = false
        isBrandSelected = false
        
        print("after reset: storedPrijs = \(storedPrijs), prijs = \(prijs), storedGewichtSpoel = \(storedGewichtSpoel), gewichtSpoel = \(gewichtSpoel), storedDichtheid = \(storedDichtheid), dichtheid = \(dichtheid), storedPartijNr= \(storedPartijNr), partijNr = \(partijNr), storedFilament = \(storedFilament), filament = \(filament), storedIsSelected = \(storedIsSelected), isSelected = \(isSelected), storedSelectedColorName = \(storedSelectedColorName), selectedColorName = \(selectedColorName), storedSelectedColorHex = \(storedSelectedColorHex), selectedColorColor = \(selectedColorColor), storedIsColorSelected = \(storedIsColorSelected), isColorSelected = \(isColorSelected), storedBrand = \(storedBrand), brand = \(brand), storedIsOtherSelected = \(storedIsOtherSelected), isOtherSelected = \(isOtherSelected) storedIsColorSelected = \(storedIsColorSelected), isColorSelected = \(isColorSelected), storedCustomColor = \(storedCustomColor), customColor = \(customColor), storedIsBrandSelected = \(storedIsBrandSelected), isBrandSelected = \(isBrandSelected), storedBrand = \(storedBrand) ")
        
        
    }
    
    private func startWrite() {
        reader.startWriter(mode: .sample)
    }
    private var blackColor: Color { Color(hex: "#000000") }
    
    fileprivate func intFromString(_ s: String) -> Int? {
        Int(s.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    fileprivate func doubleFromString(_ s: String) -> Double? {
        Double(s.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: ",", with: "."))
    }
    
    // vóór de ViewBuilder of bovenin body
    private func makeOpenSpool() -> OpenSpool {
        OpenSpool(
            id: nil,
            protocolName: "openspool",
            version: "1.0",
            brand: brand.isEmpty ? NSLocalizedString("Brand.title", comment: "Brand title") : brand,
            type: filament,
            subtype: variantText,
            color_hex: hexColor.replacingOccurrences(of: "#", with: ""),
            additional_color_hexes: customColors.isEmpty ? [] : customColors,
            alpha: "FF",
            min_temp: intFromString(minTemp) ?? 0,
            max_temp: intFromString(maxTemp) ?? 0,
            bed_min_temp: intFromString(bedMinTemp) ?? 0,
            bed_max_temp: intFromString(bedMaxTemp) ?? 0,
            weight: doubleFromString(gewicht) ?? 0.0,
            spoolweight: doubleFromString(gewichtSpoel) ?? 0.0,
            density: doubleFromString(dichtheid) ?? 0.0,
            price: doubleFromString(prijs) ?? 0.0,
            currency: currency,
            lot_nr: partijNr,
            diameter: doubleFromString(diameter) ?? 0.0
            
            
        )
    }
    // MARK: - Body
    var body: some View {
        
        NavigationStack {
            VStack(spacing: -15) {
                HeaderView(customColor: customColor, showSettings: $showSettings)
                Text("Spool Painter")
                    .font(.system(size: 30, weight: .bold))
                    .foregroundColor(customColor.lighterIfNearlyBlack())
                    .padding(.top, 14)
                    .padding(.horizontal, 12)
            }
            
            ScrollView {
                if urlText.isEmpty {
                    HStack(alignment: .center, spacing: 12) {
                        Image(systemName: "lightbulb")
                            .font(.title2)
                            .foregroundColor(.yellow)
                            .padding(.leading, 8)
                        Text(NSLocalizedString("spoolman.connect.tooltip", comment: "Tooltip voor Spoolman"))
                            .font(.caption)
                            .foregroundColor(.white)
                            .lineLimit(2)
                            .fixedSize(horizontal: false, vertical: true)
                            .padding(.vertical, 12)
                        Spacer()
                    }
                    .padding(.horizontal, 4)
                    .background(Color.white.opacity(0.15))
                    .cornerRadius(12)
                    .padding(.horizontal)
                } else {
                    // wanneer URL is ingesteld: toon selector (of jouw bestaande selector view)
                    SpoolmanFilamentSelector(
                        spoolmanIP: $spoolmanIP,
                        selectedFilamentID: $selectedFilamentID,
                        isSelectedVisual: $isSelectedVisual,
                        disableAutoApply: isResetting,  // ← MOVE THIS BEFORE onApply
                        onApply: { (filament: Filament) in
                            applyFilamentOption(filament)
                            storedGewicht = gewicht
                            storedGewichtSpoel = gewichtSpoel
                            storedDichtheid = dichtheid
                            storedDiameter = diameter
                            storedPrijs = prijs
                            storedPartijNr = partijNr
                            
                            storedMinTemp = minTemp
                            storedMaxTemp = maxTemp
                            storedBedMinTemp = bedMinTemp
                            storedBedMaxTemp = bedMaxTemp
                        }
                    )
                    
                    
                    
                    .padding(.horizontal)
                }
                
                FilamentSelectionView(
                    filament: $filament,
                    customMaterial: $customMaterial,
                    isOtherSelected: $isOtherSelected,
                    isSelected: $isSelected,
                    allFilaments: allFilaments
                )
                
                VariantField(variantText: $variantText, variantFocused: $variantFocused)
                
                ColorSelectionView(
                    selectedColorName: $selectedColorName,
                    selectedColorColor: $selectedColorColor,
                    isColorSelected: $isColorSelected,
                    showColorPickerOverlay: $showColorPickerOverlay,
                    customColor: $customColor,
                    customColors: $customColors,
                    hexColor: $hexColor,
                    colorNames: colorNames
                )
                
                BrandSelectionView(
                    brand: $brand,
                    customBrand: $customBrand,
                    isOtherBrand: $isOtherBrand,
                    scannedBrand: $scannedBrand,
                    isBrandSelected: $isBrandSelected,
                    allBrands: allBrands
                )
                
                SixFieldsTwoColumns(
                    gewicht: $gewicht,
                    gewichtSpoel: $gewichtSpoel,
                    dichtheid: $dichtheid,
                    diameter: $diameter,
                    prijs: $prijs,
                    partijNr: $partijNr,
                    gewichtEdited: $gewichtEdited,
                    gewichtSpoelEdited: $gewichtSpoelEdited,
                    dichtheidEdited: $dichtheidEdited,
                    diameterEdited: $diameterEdited,
                    prijsEdited: $prijsEdited,
                    partijNrEdited: $partijNrEdited,
                    currency: $storedCurrency
                )
                
                TemperatureBlock(
                    minTemp: $minTemp, maxTemp: $maxTemp,
                    bedMinTemp: $bedMinTemp, bedMaxTemp: $bedMaxTemp,
                    nozzleMinBorderColor: $nozzleMinBorderColor,
                    nozzleMaxBorderColor: $nozzleMaxBorderColor,
                    bedMinBorderColor: $bedMinBorderColor,
                    bedMaxBorderColor: $bedMaxBorderColor
                )
            
                if let spool = reader.lastSpool {
                    HStack {
                        Rectangle()
                            .fill(Color(hex: spool.color_hex ?? "") )
                            .frame(width: 48, height: 48)
                            .padding(.top, 6)
                            .cornerRadius(6)
                        
                        VStack(alignment: .leading) {
                            Text(spool.brand ?? NSLocalizedString("read.spool.unknown", comment: "Unknown spool")).bold()
                            Text("\(spool.type ?? "-") / \(spool.subtype ?? "-")")
                            Text(spool.color_hex ?? "-").font(.caption)
                            if let additionalColors = spool.additional_color_hexes {
                                Text("\(NSLocalizedString("read.spool.xtracolors", comment: "Extra Colors spool")) \(additionalColors.joined(separator: ", "))")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                            }
                            if let weight = spool.weight {
                                Text("\(NSLocalizedString("read.spool.weight", comment: "Weight label")) \(String(format: "%.0f", weight))g")
                                    .font(.caption)
                            }
                            
                            if let diameter = spool.diameter {
                                Text("\(NSLocalizedString("read.spool.diameter", comment: "Diameter label"))\(String(format: "%.2f", diameter)) mm").font(.caption)
                            }
                            if let minTemp = spool.min_temp, let maxTemp = spool.max_temp {
                                Text("Nozzle Temp: \(minTemp)°C - \(maxTemp)°C")
                                    .font(.caption)
                            }
                            if let bedMinTemp = spool.bed_min_temp, let bedMaxTemp = spool.bed_max_temp {
                                Text("Bed Temp: \(bedMinTemp)°C - \(bedMaxTemp)°C")
                                    .font(.caption)
                            }
                            if let spoolweight = spool.spoolweight {
                                Text("\(NSLocalizedString("read.spool.spoolweight", comment: "Spoolweight label"))\(String(format: "%.0f", spoolweight))g").font(.caption)
                            }
                            if let density = spool.density {
                                Text("\(NSLocalizedString("read.spool.density", comment: "Density label"))\(String(format: "%.2f", density)) ").font(.caption)
                            }
                            if let price = spool.price {
                                Text("\(NSLocalizedString("read.spool.price", comment: "Price label")) \(String(format: "%.2f", price)) \(storedCurrency)")
                                    .font(.caption)
                            } else {
                                Text("\(NSLocalizedString("read.spool.price", comment: "Price label")) —")
                                    .font(.caption)
                            }
                            if let lot_nr = spool.lot_nr {
                                Text("\(NSLocalizedString("read.spool.lotnr", comment: "Lotnr label")) \(lot_nr)").font(.caption)
                            }
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(selectedSpool == spool ? Color.yellow : Color.clear, lineWidth: 2)
                            .animation(.easeInOut, value: selectedSpool)
                    )
                    .onTapGesture {
                        withAnimation { selectedSpool = (selectedSpool == spool) ? nil : spool }
                    }
                    .onSubmit { commitFieldsToModel() }
                    .onAppear {
                        // zet selectie als deze spool door NFC is gedetecteerd
                        DispatchQueue.main.async {
                            withAnimation(.none) { selectedSpool = spool }
                            // ensure density field shows two decimals
                            if let d = reader.lastSpool?.density {
                            dichtheid = String(format: "%.2f", d)
                            }
                        }
                    }
  
                } else {
                    Text(NSLocalizedString("read.spool.info", comment: "Info about spool")).font(.caption)
                }
                
                NFCControlsView(
                    brand: $brand,
                    filament: $filament,
                    variantText: $variantText,
                    hexColor: $hexColor,
                    customColors: $customColors,
                    minTemp: $minTemp,
                    maxTemp: $maxTemp,
                    bedMinTemp: $bedMinTemp,
                    bedMaxTemp: $bedMaxTemp,
                    gewicht: $gewicht,
                    gewichtSpoel: $gewichtSpoel,
                    dichtheid: $dichtheid,
                    prijs: $prijs,
                    currency: $currency,
                    partijNr: $partijNr,
                    diameter: $diameter,
                    reader: reader,
                    onRequestWrite: {
                        reader.pendingOpenSpool = makeOpenSpool()
                        reader.startWriter(mode: .sample)
                    },
                    onWriterClearAndReset: { reader.startWriter(mode: .clear) },
                    onReaderAndReset: { reader.startReader() }
                )
                .padding()
                .background(Color.black)
                .cornerRadius(12)
                .padding(.horizontal)
                .padding(.top, 8)
                .onChange(of: reader.lastSpool?.type) { _, newValue in
                    guard !isResetting else { return }
                    guard let scannedRaw = newValue?.trimmingCharacters(in: .whitespacesAndNewlines),
                          !scannedRaw.isEmpty else { return }
                    
                    let scannedNorm = scannedRaw.uppercased()
                    let normalizedPresets = allFilaments.map { $0.trimmingCharacters(in: .whitespacesAndNewlines).uppercased() }
                    
                    DispatchQueue.main.async {
                        if normalizedPresets.contains(scannedNorm) {
                            // zit in presets: selecteer juiste dropdown-item en clear vrije invoer
                            filament = scannedRaw                // dropdown-binding
                            customMaterial = ""                   // vrije invoer leegmaken
                            isOtherSelected = false
                            isSelected = true
                        } else {
                            // niet in presets: open "Ander" en vul het vrije invoerveld
                            filament = "Anders"                   // of de key/label die de dropdown naar "Ander" schakelt
                            customMaterial = scannedRaw           // vul het toevoegvak met gescande waarde
                            isOtherSelected = true
                            isSelected = true
                        }
                        
                        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                            isSelected = (scannedNorm == "PLA") || isOtherSelected || normalizedPresets.contains(scannedNorm)
                        }
                    }
                }
                .onChange(of: reader.lastSpool?.subtype) {_,  newValue in
                    guard let subtype = newValue, !subtype.isEmpty else { return }
                    print("onChange fired:", subtype)
                    variantText = subtype
                }
                .onChange(of: reader.lastSpool?.color_hex) { _, newValue in
                    DispatchQueue.main.async {
                        let result = colorFromHexOrName(newValue, nameList: colorNames)
                        selectedColorName = result.name
                        selectedColorColor = result.color
                        customColor = result.color
                        isColorSelected = true
                        
                        if result.name == "Kleurkiezer" {
                            // direct toepassen en verbergen — geen gebruikersconfirmatie
                            showColorPickerOverlay = false
                        }
                    }
                }
                .onChange(of: reader.lastSpool?.brand) {_,  newValue in
                    guard let scannedBrand = newValue, !scannedBrand.isEmpty else { return }
                    DispatchQueue.main.async {
                        brand = scannedBrand
                        customBrand = ""
                        isOtherBrand = (scannedBrand == "Ander")
                        isSelected = (scannedBrand == "Algemeen" || scannedBrand == "Ander")
                        isSelected = true
                    }
                }
                .onChange(of: reader.lastSpool?.weight) {_,  newValue in
                    guard let scannedWeight = newValue else { return }
                    DispatchQueue.main.async {
                        gewicht = String(Int(scannedWeight.rounded()))
                        gewichtEdited = true
                    }
                }
                .onChange(of: reader.lastSpool?.spoolweight) {_,  newValue in
                    guard let scannedSpoolWeight = newValue else { return }
                    DispatchQueue.main.async {
                        gewichtSpoel = String(Int(scannedSpoolWeight.rounded()))
                        gewichtSpoelEdited = true
                    }
                }
                .onChange(of: reader.lastSpool?.density) {_,  newValue in
                    guard let scannedDensity = newValue else { return }
                    DispatchQueue.main.async {
                        dichtheid = String(Int(scannedDensity.rounded()))
                        dichtheidEdited = true
                    }
                }
                .onChange(of: reader.lastSpool?.price) {_,  newValue in
                    guard let scannedPrijs = newValue else { return }
                    DispatchQueue.main.async {
                        prijs = String(format: "%.2f", scannedPrijs)
                        prijsEdited = true
                    }
                }
                .onChange(of: reader.lastSpool?.currency) { _, newValue in
                    guard let scannedCurrency = newValue else { return }
                    DispatchQueue.main.async {
                        let normalized: String = {
                            let s = scannedCurrency.trimmingCharacters(in: .whitespacesAndNewlines)
                            switch s.uppercased() {
                            case "€", "EURO": return "EUR"
                            case "$", "DOLLAR": return "USD"
                            case "£", "POUND": return "GBP"
                            default: return s
                            }
                        }()
                        currency = normalized
                        // optioneel: update settings-display (AppStorage) to preferred symbol
                        switch normalized {
                        case "EUR": storedCurrency = "€"
                        case "USD": storedCurrency = "$"
                        case "GBP": storedCurrency = "£"
                        default: break
                        }
                    }
                }
                .onChange(of: reader.lastSpool?.lot_nr) {_,  newValue in
                    guard let scannedPartijNr = newValue else { return }
                    DispatchQueue.main.async {
                        partijNr = scannedPartijNr
                        partijNrEdited = true
                    }
                }
                .onChange(of: reader.lastSpool?.diameter) {_,  newValue in
                    guard let scannedDiameter = newValue else { return }
                    DispatchQueue.main.async {
                        diameter = String(format: "%.2f", scannedDiameter)
                        diameterEdited = true
                    }
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        isSelected = false
                    }
                }
                
            }
            .frame(maxWidth: .infinity)
            .onChange(of: reader.lastSpool?.type) {
                handleSpoolTemps(reader.lastSpool)
            }
            Button(NSLocalizedString("reset.fields", comment: "Reset selected fields")) {
                showingResetConfirm = true
                
            }
            .fontWeight(.semibold)
            .foregroundColor(.black)
            .padding(.vertical, 12)
            .padding(.horizontal, 8)
            .background(Color.yellow)
            .cornerRadius(8)
            .alert(NSLocalizedString("reset.allfields.text", comment: "Reset selected fields text"), isPresented: $showingResetConfirm) {
                Button(NSLocalizedString("cancel.button", comment: "Cancel button"), role: .cancel) {}
                Button(NSLocalizedString("reset.button", comment: "Reset button"), role: .destructive) {
                    restoreDefaults()
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        restoreDefaults()
                        refreshToggle.toggle()
                    }
                }
            }
        }
        
        .overlay(
            colorPickerOverlay
                .cornerRadius(6)
                .offset(x: -12, y: 20),
            alignment: .topTrailing
        )
        .sheet(isPresented: $showSettings) {
            SettingsView()
        }
    }
    
    // MARK: - Helpers & subviews
    // Verwachte Filament volgens jouw API (gebruik juiste types)
    struct FilamentAPI {
        let id: Int
        let name: String
        let vendor: VendorAPI
        let material: String?
        let article_number: String?
        let color_hex: String?
        let price: Double?
        let diameter: Double?
        let weight: Double?
        let spool_weight: Double?
        let settings_extruder_min_temp: Int?
        let settings_extruder_max_temp: Int?
        let settings_bed_min_temp: Int?
        let settings_bed_max_temp: Int?
        let density: Double?
        let registered: String?
        let extra: [String: Any]?
    }
    struct VendorAPI { let id: Int; let registered: String; let name: String; let empty_spool_weight: Double; let extra: [String: Any]? }
    
    // kleur-fallback parser (blijft, alleen als geen color_hex)
    func parseColorName(from productName: String) -> String {
        let candidates = ["black","white","red","blue","yellow","green","orange","pink","purple","brown","gray","grey","silver","gold"]
        let parts = productName.lowercased().split(separator: " ").map { String($0).trimmingCharacters(in: .punctuationCharacters) }
        for p in parts.reversed() { if candidates.contains(p) { return p.capitalized } }
        if let last = parts.last, last.rangeOfCharacter(from: CharacterSet.letters) != nil { return last.capitalized }
        return ""
    }
    
    
    
    // Definitieve apply — gebruikt alleen API-velden in prioriteit
    func applyFilamentOption(_ f: Filament) {
        // If reset is happening, ignore completely
        guard !isResetting else {
                print("Reset in progress - skipping weight/diameter")
                return
            }
            
            print("⚠️ applyFilamentOption called for: \(f.name)")
        print("DBG before assign gewicht:", gewicht)
        if let w = f.weight { gewicht = String(Int(w)) } else { gewicht = "" }
        print("DBG after assign gewicht:", gewicht)
        
        print("DBG before assign diameter:", diameter)
        if let diam = f.diameter { diameter = String(diam) } else { diameter = "" }
        print("DBG after assign diameter:", diameter)
        
        print("DBG before assign minTemp:", minTemp)
        if let minE = f.settings_extruder_min_temp { minTemp = String(minE); storedMinTemp = minTemp } else { minTemp = ""; storedMinTemp = "" }
        print("DBG after assign minTemp:", minTemp)
        // 1) Materiaal
        filament = (f.material ?? f.name).trimmingCharacters(in: .whitespacesAndNewlines)
        customMaterial = ""
        isOtherSelected = false
        isSelected = true
        
        // 2) Merk: vendor.name (API)
        let vendorName = f.vendor!.name.trimmingCharacters(in: .whitespacesAndNewlines)
        brand = vendorName
        storedBrand = vendorName
        
        let raw = f.name.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // vervang veelvoorkomende scheidingstekens door spatie
        let separators = CharacterSet(charactersIn: "+-|/,")
        var normalized = raw.components(separatedBy: separators).joined(separator: " ")
        
        // collapse meerdere spaties naar één
        while normalized.contains("  ") { normalized = normalized.replacingOccurrences(of: "  ", with: " ") }
        normalized = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // splits en kies tweede token als variant
        let parts = normalized.components(separatedBy: CharacterSet.whitespaces).filter { !$0.isEmpty }
        if parts.count >= 2 {
            variantText = parts[1]
        } else {
            variantText = normalized
        }
        // dichtheid, diameter, gewicht, gewichtSpoel (spool weight)
        if let d = f.density { dichtheid = String(d) } else { dichtheid = "" }
        if let w = f.weight {
            gewicht = String(Int(w))
            gewichtEdited = true
        } else {
            gewicht = ""
            gewichtEdited = false
        }
        
        if let d = f.diameter {
            diameter = String(d)
            diameterEdited = true
        } else {
            diameter = ""
            diameterEdited = false
        }
        if let s = f.spool_weight { gewichtSpoel = String(Int(s)) } else { gewichtSpoel = "" }
        
        // partijnummer (article)
        if let part = f.article_number?.trimmingCharacters(in: .whitespacesAndNewlines), !part.isEmpty {
            partijNr = part
        } else {
            partijNr = ""
        }
        // 4) Kleur
        // in applyFilamentOption, vervang je kleurblok door:
        let baseToken = baseColorToken(from: f.name)
        let lang = currentAppLanguage
        
        if let hex = f.color_hex?.trimmingCharacters(in: .whitespacesAndNewlines), !hex.isEmpty {
            selectedColorName = localizedColorName(for: baseToken, lang: lang)
            selectedColorColor = Color(hex: hex).lighterIfNearlyBlack()
            isColorSelected = true
            
            storedSelectedColorHex = hex.hasPrefix("#") ? hex : "#" + hex
        } else if let lookup = colorLookupCache[baseToken.lowercased()] {
            let comps = lookup.components(separatedBy: "|").map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }.filter { !$0.isEmpty }
            if comps.count == 2 {
                selectedColorName = comps[0]
                selectedColorColor = Color(hex: comps[1]).lighterIfNearlyBlack()
                isColorSelected = true
                storedSelectedColorHex = comps[1].hasPrefix("#") ? comps[1] : "#" + comps[1]
            } else if comps.count == 1 {
                if comps[0].hasPrefix("#") || comps[0].range(of: "^[0-9A-Fa-f]{6}$", options: .regularExpression) != nil {
                    selectedColorName = localizedColorName(for: baseToken, lang: lang)
                    selectedColorColor = Color(hex: comps[0]).lighterIfNearlyBlack()
                    isColorSelected = true
                    storedSelectedColorHex = comps[0].hasPrefix("#") ? comps[0] : "#" + comps[0]
                } else {
                    selectedColorName = comps[0]
                    selectedColorColor = .gray
                    isColorSelected = true
                    storedSelectedColorHex = ""
                    
                }
            }
        } else {
            let parsed = parseColorName(from: f.name)
            if !parsed.isEmpty {
                selectedColorName = localizedColorName(for: parsed, lang: lang)
                selectedColorColor = .gray
                isColorSelected = true
                storedSelectedColorHex = ""
            } else {
                selectedColorName = ""
                selectedColorColor = .gray
                isColorSelected = false
                storedSelectedColorHex = ""
            }
        }
        
        // temperaturen
        if let minE = f.settings_extruder_min_temp {
            minTemp = String(minE)
            storedMinTemp = minTemp
            nozzleMinBorderColor = .yellow
        } else {
            minTemp = ""
            storedMinTemp = ""
            nozzleMinBorderColor = .clear
        }
        
        if let maxE = f.settings_extruder_max_temp {
            maxTemp = String(maxE)
            storedMaxTemp = maxTemp
            nozzleMaxBorderColor = .yellow
        } else {
            maxTemp = ""
            storedMaxTemp = ""
            nozzleMaxBorderColor = .clear
        }
        
        if let bedMin = f.settings_bed_min_temp {
            bedMinTemp = String(bedMin)
            storedBedMinTemp = bedMinTemp
            bedMinBorderColor = .yellow
        } else {
            bedMinTemp = ""
            storedBedMinTemp = ""
            bedMinBorderColor = .clear
        }
        
        if let bedMax = f.settings_bed_max_temp {
            bedMaxTemp = String(bedMax)
            storedBedMaxTemp = bedMaxTemp
            bedMaxBorderColor = .yellow
        } else {
            bedMaxTemp = ""
            storedBedMaxTemp = ""
            bedMaxBorderColor = .clear
        }
        
        // overige velden (price e.d.) — voeg toe indien nodig
        if let p = f.price { prijs = String(format: "%.2f", p) } else { prijs = "" }
        
        // visuele flags / ids
        selectedFilamentID = f.id
        isSelectedVisual = true
        isSelected = true
        storedIsSelected = true
        storedSelectedFilamentID = f.id
        
        DispatchQueue.main.async {
            customColor = colorForLogo(selectedColorColor)
            hexColor = storedSelectedColorHex.isEmpty ? hexColor : (storedSelectedColorHex.hasPrefix("#") ? storedSelectedColorHex : "#" + storedSelectedColorHex)
            isResetting = false
            refreshToggle.toggle()
        }
    }
    
    
    private var colorPickerOverlay: some View {
        Group {
            if showColorPickerOverlay {
                ZStack {
                    Color.black.opacity(0.5)
                        .edgesIgnoringSafeArea(.all)
                        .onTapGesture { showColorPickerOverlay = false }
                    
                    ColorPickerView(
                        selectedColor: $customColor,
                        showColorPicker: $showColorPickerOverlay,
                        customColors: $customColors,
                        hexCode: $hexColor,
                        isColorSelected: $isColorSelected
                    )
                    .frame(width: 350, height: 500)
                    .cornerRadius(20)
                    .shadow(radius: 10)
                }
            }
        }
    }
    private func handleSpoolTemps(_ spool: OpenSpool?) {
        guard let spool = spool else { return }
        
        func doubleFromAny(_ value: Any) -> Double? {
            switch value {
            case let d as Double: return d
            case let i as Int: return Double(i)
            case let f as Float: return Double(f)
            case let s as String: return Double(s)
            case let n as NSNumber: return n.doubleValue
            default: return nil
            }
        }
        
        if let v = spool.min_temp {
            if let dv = doubleFromAny(v) {
                minTemp = String(Int(dv.rounded()))
                nozzleMinBorderColor = .yellow
            }
        }
        if let v = spool.max_temp {
            if let dv = doubleFromAny(v) {
                maxTemp = String(Int(dv.rounded()))
                nozzleMaxBorderColor = .yellow
            }
        }
        if let v = spool.bed_min_temp {
            if let dv = doubleFromAny(v) {
                bedMinTemp = String(Int(dv.rounded()))
                bedMinBorderColor = .yellow
            }
        }
        if let v = spool.bed_max_temp,
           let dv = doubleFromAny(v) {
            bedMaxTemp = String(Int(dv.rounded()))
            bedMaxBorderColor = .yellow
        }
        
    }
    
    
    
    
    
    
    // MARK: - HeaderView
    private struct HeaderView: View {
        var customColor: Color
        @Binding var showSettings: Bool
        
        var body: some View {
            HStack {
                let _ = Color(hex: "#000000")
                Image("pjfk601")
                    .renderingMode(.template)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .foregroundColor(customColor.lighterIfNearlyBlack())
                    .padding(.top, -36)
                    .toolbar {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button {
                                showSettings = true
                            } label: {
                                VStack(spacing: 2) {
                                    Circle().frame(width: 8, height: 8).foregroundColor(.yellow)
                                    Circle().frame(width: 8, height: 8).foregroundColor(.yellow)
                                    Circle().frame(width: 8, height: 8).foregroundColor(.yellow)
                                }
                                .padding(8)                     // vergroot hit area
                                .contentShape(Rectangle())      // maak hele rechthoek tappable
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
            }
        }
    }
    
    
    
    
    
    //Mark: - ColorSelectionRow
    struct ColorSelectionRow: View {
        @State private var selectedHex: String = ""          // bv. "#RRGGBB" of lege string
        @State private var selectedColor: Color = .white     // voor weergave/icoon
        // Als je al een model-variabele hebt, gebruik die in plaats van lokale state
        
        var body: some View {
            HStack {
                Image(systemName: "paintpalette")
                    .foregroundColor(selectedColor) // icoon in gekozen kleur
                    .font(.title2)
                
                // Als je een ColorPicker wilt:
                ColorPicker("", selection: Binding(
                    get: { selectedColor },
                    set: { newColor in
                        selectedColor = newColor
                        selectedHex = selectedColor.toHexString() ?? selectedHex
                    }))
                .labelsHidden()
                // OF: als je een Picker met tekstveld wil tonen:
                Text(selectedHex) // toont hex-waarde als label (of vervang door naam)
                    .foregroundColor(.primary)
            }
            
        }
    }
}


    // MARK: - Previews
    #Preview {
        ContentView()
    }


    #if canImport(UIKit)
    private func colorForLogo(_ c: Color) -> Color {
    isNearBlack(c) ? Color(.darkGray) : c
    }
    private func isNearBlack(_ c: Color) -> Bool {
    let ui = UIColor(c)
    var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
    ui.getRed(&r, green: &g, blue: &b, alpha: &a)
    return r < 0.06 && g < 0.06 && b < 0.06
    }
    private func colorForApp(_ c: Color) -> Color {
    // same behavior as colorForLogo; return whichever substitute you prefer
    isNearBlack(c) ? Color(.black) : c
    }
    #else
    private func colorForLogo(_ c: Color) -> Color { c }
    private func colorForApp(_ c: Color) -> Color { c }
    #endif
