import SwiftUI

struct SixFieldsTwoColumns: View {
   // Fields
   @Binding var gewicht: String
   @Binding var gewichtSpoel: String
   @Binding var dichtheid: String
   @Binding var diameter: String
   @Binding var prijs: String
   @Binding var partijNr: String

   // Edited flags
   @Binding var gewichtEdited: Bool
   @Binding var gewichtSpoelEdited: Bool
   @Binding var dichtheidEdited: Bool
   @Binding var diameterEdited: Bool
   @Binding var prijsEdited: Bool
   @Binding var partijNrEdited: Bool

   // Currency binding for price picker
   @Binding var currency: String
    var keyboard: UIKeyboardType = .numbersAndPunctuation
    
  
    
   

   var body: some View {
       VStack(spacing: 12) {
       HStack(spacing: 12) {
           LabeledField(
               text: $gewicht,
               edited: $gewichtEdited,
               title: NSLocalizedString("weight.title", comment: "Weihgt title"),
               infoTitle: NSLocalizedString("weight.infotitle", comment: "Info title weight"),
               infoText: NSLocalizedString("weight.infotext", comment: "Info text weight"),
               badgeOffsetX: 12,
               badgeOffsetY: -10,
               placeholder: "gram",
               keyboard: keyboard
           )
           .frame(maxWidth: .infinity)


           LabeledField(
               text: $gewichtSpoel,
               edited: $gewichtSpoelEdited,
               title: NSLocalizedString("weight.spool.title", comment: "Weihgt spool title"),
               infoTitle: NSLocalizedString("weight.spool.infotitle", comment: "Infotitle spool weight"),
               infoText: NSLocalizedString("weight.spool.infotext", comment: "Infotext spool weight"),
               badgeOffsetX: 12,
               badgeOffsetY: -10,
               placeholder: "gram",
               keyboard: keyboard
           )
           .frame(maxWidth: .infinity)
       }

       HStack(spacing: 12) {
           LabeledField(
               text: $dichtheid,
               edited: $dichtheidEdited,
               title: NSLocalizedString("density.title", comment: "Density title"),
               badgeOffsetX: 12,
               badgeOffsetY: -10,
               placeholder: "g/cm³",
               keyboard: keyboard
               
           )
           .frame(maxWidth: .infinity)
           

           LabeledField(
               text: $diameter,
               edited: $diameterEdited,
               title: NSLocalizedString("diameter.title", comment: "Diameter title"),
               badgeOffsetX: 12,
               badgeOffsetY: -10,
               placeholder: "1.75 mm",
               keyboard: keyboard
           )
           .frame(maxWidth: .infinity)
       }
           

       HStack(spacing: 12) {
           PriceField(price: $prijs,
           currency: $currency,
           edited: $prijsEdited)
               .padding(.top, -20)
               .frame(maxWidth: .infinity)

           LabeledField(
               text: $partijNr,
               edited: $partijNrEdited,
               title:  NSLocalizedString("SKU.title", comment: "SKU title"),
               infoTitle: NSLocalizedString("SKU.infotitle", comment: "SKU infotitle"),
               infoText: NSLocalizedString("SKU.infotext", comment: "SKU infotext"),
               badgeOffsetX: 12,
               badgeOffsetY: -10,
               placeholder: "SKU nr:"
           )
           .padding(.top, 10)
           .frame(maxWidth: .infinity)
           }
       }
       .padding(.horizontal, 4)
       .padding(.top, 18)
   }
}
