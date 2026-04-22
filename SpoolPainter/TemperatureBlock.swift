import SwiftUI

/// MARK: - TemperatureBlock
struct TemperatureBlock: View {
    @Binding var minTemp: String
    @Binding var maxTemp: String
    @Binding var bedMinTemp: String
    @Binding var bedMaxTemp: String
    
    @Binding var nozzleMinBorderColor: Color
    @Binding var nozzleMaxBorderColor: Color
    @Binding var bedMinBorderColor: Color
    @Binding var bedMaxBorderColor: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(NSLocalizedString("temperature.title", comment: "Title Temperature"))
                .font(.system(size: 16))
                .foregroundColor(.white)
                .padding(.top, 2)
            
            // Nozzle row: two controls with flexible spacer between them
            HStack(spacing: 0) {
                tempControl(label: "Nozzle", value: $minTemp, border: $nozzleMinBorderColor, decrement: -5, increment: 5)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                Spacer(minLength: 16)
                
                tempControl(label: "", value: $maxTemp, border: $nozzleMaxBorderColor, decrement: -5, increment: 5)
                    .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
            
            // Bed row: same layout
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 0) {
                    tempControl(label: "Bed", value: $bedMinTemp, border: $bedMinBorderColor, decrement: -5, increment: 5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                    
                    Spacer(minLength: 16)
                    
                    tempControl(label: "", value: $bedMaxTemp, border: $bedMaxBorderColor, decrement: -5, increment: 5)
                        .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .padding()
        .background(Color.black)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
    private func tempControl(label: String, value: Binding<String>, border: Binding<Color>, decrement: Int, increment: Int) -> some View {
        HStack(spacing: 10) {
            if !label.isEmpty {
                Text(label)
                    .font(.system(size: 16))
                    .foregroundColor(.white)
                    .frame(minWidth: 60, alignment: .leading)
            }
            
            Button {
                if let v = Int(value.wrappedValue), v > 0 {
                    value.wrappedValue = String(v + decrement)
                }
                border.wrappedValue = .yellow
            } label: {
                Image(systemName: "minus")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PlainButtonStyle())
            
            TextField("", text: value)
                .keyboardType(.numberPad)
                .multilineTextAlignment(.center)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 60, height: 36)
                .overlay(RoundedRectangle(cornerRadius: 8).stroke(border.wrappedValue, lineWidth: 3))
            
            Button {
                if let v = Int(value.wrappedValue) {
                    value.wrappedValue = String(v + increment)
                } else {
                    value.wrappedValue = String(abs(increment))
                }
                border.wrappedValue = .yellow
            } label: {
                Image(systemName: "plus")
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
}
