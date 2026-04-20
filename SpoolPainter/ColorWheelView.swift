import SwiftUI
import UIKit

// --- ColorWheelView (hue/saturation bindings) ---
struct ColorWheelView: View {
    @Binding var hue: Double        // 0...1
    @Binding var saturation: Double // 0...1

    @State private var wheelSize: CGSize = .zero
    @State private var pickerPosition: CGPoint = .zero

    var body: some View {
        GeometryReader { geometry in
            let size = min(geometry.size.width, geometry.size.height)
            ZStack {
                AngularGradient(gradient: Gradient(colors: [
                    .red, .orange, .yellow, .green, .blue, .purple, .red
                ]), center: .center)
                .frame(width: size, height: size)
                .clipShape(Circle())

                RadialGradient(gradient: Gradient(colors: [Color.white, Color.white.opacity(0)]),
                               center: .center,
                               startRadius: 0,
                               endRadius: size / 2)
                    .frame(width: size, height: size)
                    .blendMode(.overlay)
                    .clipShape(Circle())

                Circle()
                    .stroke(Color.white, lineWidth: 3)
                    .frame(width: 24, height: 24)
                    .position(pickerPosition)

                Circle()
                    .stroke(Color.black.opacity(0.6), lineWidth: 1)
                    .frame(width: 24, height: 24)
                    .position(pickerPosition)

                Circle()
                    .fill(Color(hue: hue, saturation: saturation, brightness: 1.0))
                    .frame(width: 20, height: 20)
                    .position(pickerPosition)
                    .gesture(
                        DragGesture(minimumDistance: 0)
                            .onChanged { value in
                                updateFrom(location: value.location, in: geometry.size)
                            }
                    )
            }
            .onAppear {
                wheelSize = CGSize(width: size, height: size)
                updatePickerPosition(in: geometry.size)
            }
            .onChange(of: geometry.size) { oldValue, newValue in
                wheelSize = CGSize(width: size, height: size)
                updatePickerPosition(in: geometry.size)
            }
            .onChange(of: hue) { oldValue, newValue in updatePickerPosition(in: geometry.size) }
            .onChange(of: saturation) { oldValue, newValue in updatePickerPosition(in: geometry.size) }
            
        }
    }

    private func updatePickerPosition(in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2
        let angle = hue * 2 * .pi
        let distance = saturation * radius
        let x = center.x + cos(angle) * distance
        let y = center.y + sin(angle) * distance
        pickerPosition = CGPoint(x: x, y: y)
    }

    private func updateFrom(location: CGPoint, in size: CGSize) {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let radius = min(size.width, size.height) / 2

        let dx = location.x - center.x
        let dy = location.y - center.y
        let distance = sqrt(dx*dx + dy*dy)
        let clampedDistance = min(distance, radius)

        var angle = atan2(dy, dx)
        if angle < 0 { angle += 2 * .pi }

        let newHue = Double(angle / (2 * .pi))
        let newSat = Double(clampedDistance / radius)

        hue = newHue
        saturation = newSat

        let x = center.x + cos(angle) * clampedDistance
        let y = center.y + sin(angle) * clampedDistance
        pickerPosition = CGPoint(x: x, y: y)
    }
}
