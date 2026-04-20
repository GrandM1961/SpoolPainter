import SwiftUI

struct TemperatureView: View {
    @State private var nozzleTemp = 200
    @State private var bedTemp = 60
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text(NSLocalizedString("temperature.title", comment: "Title Temperature")).font(.headline)
            
            HStack {
                Text("Nozzle: \(nozzleTemp)°C")
                Spacer()
                HStack {
                    Button("-5") { nozzleTemp = max(0, nozzleTemp-5) }
                    Button("+5") { nozzleTemp += 5 }
                }
                .frame(maxWidth: .infinity)
            }
            .padding()
            .background(Color.orange.opacity(0.1))
            .cornerRadius(10)
            
            HStack {
                Text("Bed: \(bedTemp)°C")
                Spacer()
                HStack {
                    Button("-5") { bedTemp = max(0, bedTemp-5) }
                    Button("+5") { bedTemp += 5 }
                }
            }
            .padding()
            .background(Color.red.opacity(0.1))
            .cornerRadius(10)
        }
        .frame(maxWidth: .infinity)
    }
        
}
