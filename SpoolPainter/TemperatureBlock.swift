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
            
            HStack(spacing: 20) {
                tempControl(label: "Nozzle", value: $minTemp, border: $nozzleMinBorderColor, decrement: -5, increment: 5)
                tempControl(label: "", value: $maxTemp, border: $nozzleMaxBorderColor, decrement: -5, increment: 5)
            }
            
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 20) {
                    tempControl(label: "Bed     ", value: $bedMinTemp, border: $bedMinBorderColor, decrement: -5, increment: 5)
                    tempControl(label: "", value: $bedMaxTemp, border: $bedMaxBorderColor, decrement: -5, increment: 5)
                }
            }
        }
        .padding()
        .background(Color.black)
        //.cornerRadius(12)
        //.overlay(RoundedRectangle(cornerRadius: 12).stroke(Color(.gray), lineWidth: 3))
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 10)
    }
    
    @ViewBuilder
        private func tempControl(label: String, value: Binding<String>, border: Binding<Color>, decrement: Int, increment: Int) -> some View {
            HStack(spacing: 8) {
                if !label.isEmpty {
                    Text(label).font(.system(size: 16)).padding(.top, 8)
                }
                
                Button("-") {
                    if let v = Int(value.wrappedValue), v > 0 {
                        value.wrappedValue = String(v + decrement)
                    }
                    border.wrappedValue = .yellow
                }
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 5)
                .padding(.top, 10)
                
                TextField("", text: value)
                    .frame(width: 52)
                    .multilineTextAlignment(.center)
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
                    .cornerRadius(10)
                    .overlay(RoundedRectangle(cornerRadius: 10).stroke(border.wrappedValue, lineWidth: 3))
                    .padding(.top, 7)
                
                Button("+") {
                    if let v = Int(value.wrappedValue) {
                        value.wrappedValue = String(v + increment)
                    } else {
                        value.wrappedValue = String(abs(increment))
                    }
                    border.wrappedValue = .yellow
                }
                .font(.title2.bold())
                .foregroundColor(.white)
                .padding(.horizontal, 10)
                .padding(.top, 7)
            }
        }
    }
