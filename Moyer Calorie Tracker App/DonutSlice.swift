//
//  DonutSlice.swift
//  Moyer Calorie Tracker App
//
//  Created by Christian Moyer on 2/28/25.
//
import SwiftUI


struct DonutSlice: Shape {
    let startAngle: Angle
    let endAngle: Angle
    let innerRatio: CGFloat
    let clockwise: Bool
    
    func path(in rect: CGRect) -> Path {
        let width  = rect.width
        let height = rect.height
        let radius = min(width, height) / 2
        let center = CGPoint(x: width / 2, y: height / 2)
        let innerRadius = radius * innerRatio
        
        var path = Path()
        
        path.addArc(center: center, radius: radius,
                    startAngle: startAngle, endAngle: endAngle, clockwise: clockwise)
        path.addArc(center: center, radius: innerRadius,
                    startAngle: endAngle, endAngle: startAngle, clockwise: !clockwise)
        
        path.closeSubpath()
        return path
    }
}

struct PartialDonutChart: View {
    let data: [(label: String, value: Double)]
    let colors: [Color]
    let arcFraction: Double
    let startAngle: Angle
    let innerRatio: CGFloat
    let clockwise: Bool
    
    let dailyGoal: Double

    var body: some View {
        GeometryReader { geo in
            let slices = makeSlices()
            
            ZStack {
                DonutSlice(
                    startAngle: startAngle,
                    endAngle:   Angle(degrees: startAngle.degrees + 360.0 * arcFraction),
                    innerRatio: innerRatio,
                    clockwise:  clockwise
                )
                .fill(Color.gray.opacity(0.2))
                

                ForEach(slices.indices, id: \.self) { i in
                    let slice = slices[i]
                    DonutSlice(
                        startAngle: slice.startAngle,
                        endAngle:   slice.endAngle,
                        innerRatio: innerRatio,
                        clockwise:  clockwise
                    )
                    .fill(slice.color)
                }
            }
            .frame(width: geo.size.width, height: geo.size.height)
        }
    }
    
    private func makeSlices() -> [(
        startAngle: Angle,
        endAngle:   Angle,
        color:      Color
    )] {
        var results: [(
            startAngle: Angle,
            endAngle:   Angle,
            color:      Color
        )] = []
        
        let total = data.reduce(0) { $0 + $1.value }
        let fillFactor = min(total, dailyGoal) / dailyGoal
        let maxArcDegrees = 360.0 * arcFraction
        let usedArcDegrees = maxArcDegrees * fillFactor
        
        guard total > 0 else { return results }

        var currentDegrees = startAngle.degrees
        
        for (index, pair) in data.enumerated() {
            let fraction     = pair.value / total
            let sliceDegrees = usedArcDegrees * fraction
            
            let sliceStart = Angle(degrees: currentDegrees)
            let sliceEnd   = Angle(degrees: currentDegrees + sliceDegrees)
            
            results.append((
                startAngle: sliceStart,
                endAngle:   sliceEnd,
                color:      colors[index % colors.count]
            ))
            
            currentDegrees += sliceDegrees
        }
        return results
    }
}
