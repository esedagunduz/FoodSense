//
//  AnalyticsCharts.swift
//  FoodSense
//
//  Created by ebrar seda gündüz on 17.01.2026.
//

import SwiftUI

struct CalorieTrendChart: View {
    let trendData: TrendData
    let period: AnalyticsPeriod
    
    var body: some View {
        GeometryReader { geometry in
            let chartHeight = geometry.size.height - 40
            let chartWidth = geometry.size.width - 40
            let displayPoints = period.shouldShowAllPoints ? trendData.dataPoints : ChartDataSampler.sample(points: trendData.dataPoints, maxPoints: 7)
            
            VStack(spacing: 0) {
                ZStack(alignment: .bottomLeading) {
                    GoalLine(goal: trendData.goalCalories, max: trendData.maxValue, height: chartHeight, color: AppColors.accent)
                    CurvePath(points: displayPoints, goal: trendData.goalCalories, max: trendData.maxValue, width: chartWidth, height: chartHeight)
                        .padding(.leading, 40)
                }
                .frame(height: chartHeight)
                
                XAxisLabels(points: displayPoints, period: period)
                    .padding(.leading, 40)
            }
        }
    }
}

struct MacroChart: View {
    let title: String
    let data: [DataPoint]
    let goal: Double
    let color: Color
    let period: AnalyticsPeriod
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(AppColors.primaryText)
            
            GeometryReader { geometry in
                let chartHeight: CGFloat = 80
                let maxValue = max(goal * 2, (data.map(\.value).max() ?? 0) * 1.1)
                let displayData = period.shouldShowAllPoints ? data : ChartDataSampler.sample(points: data, maxPoints: 7)
                
                VStack(spacing: 0) {
                    ZStack(alignment: .bottomLeading) {
                        GoalLine(goal: goal, max: maxValue, height: chartHeight, color: color)
                        BarChart(data: displayData, max: maxValue, color: color, goal: goal, height: chartHeight)
                            .padding(.leading, 40)
                    }
                    .frame(height: chartHeight)
                    
                    XAxisLabels(points: displayData, period: period)
                        .padding(.leading, 40)
                }
            }
            .frame(height: 100)
            
            Divider().background(AppColors.primaryText.opacity(0.3))
        }
    }
}

struct GoalLine: View {
    let goal: Double
    let max: Double
    let height: CGFloat
    let color: Color
    
    var body: some View {
        let goalY = height * (1 - (goal / max))
        return ZStack(alignment: .leading) {
            Text("\(Int(goal))")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(color)
                .frame(width: 35)
                .position(x: 17.5, y: goalY)
            
            Path { path in
                path.move(to: CGPoint(x: 35, y: goalY))
                path.addLine(to: CGPoint(x: 1000, y: goalY))
            }
            .stroke(color.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [4, 4]))
        }
        .frame(height: height)
    }
}

struct XAxisLabels: View {
    let points: [DataPoint]
    let period: AnalyticsPeriod
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(displayLabels, id: \.offset) { item in
                Text(item.label)
                    .font(.system(size: 10))
                    .foregroundColor(AppColors.secondaryText)
                    .frame(maxWidth: .infinity)
            }
        }
        .padding(.top, 4)
    }
    
    private var displayLabels: [(offset: Int, label: String)] {
        if period == .monthly {
            let indices = [0, 4, 9, 14, 19, 24, 29].filter { $0 < points.count }
            return indices.map { ($0, points[$0].label(for: period)) }
        } else {
            return points.enumerated().map { ($0, $1.label(for: period)) }
        }
    }
}

struct CurvePath: View {
    let points: [DataPoint]
    let goal: Double
    let max: Double
    let width: CGFloat
    let height: CGFloat
    
    var body: some View {
        let spacing = points.count > 1 ? width / CGFloat(points.count) : 0
        let offset = spacing / 2
        let cgPoints = points.enumerated().map { index, point in
            (point: CGPoint(x: offset + CGFloat(index) * spacing, y: height * (1 - (point.value / max))),
             isAbove: point.value > goal)
        }
        
        return ZStack {
            ForEach(0..<cgPoints.count, id: \.self) { index in
                Circle()
                    .fill(cgPoints[index].isAbove ? AppColors.primaryText.opacity(0.7) : AppColors.accent)
                    .frame(width: 6, height: 6)
                    .position(cgPoints[index].point)
            }
            
            ForEach(0..<cgPoints.count - 1, id: \.self) { index in
                Path { path in
                    let current = cgPoints[index].point
                    let next = cgPoints[index + 1].point
                    path.move(to: current)
                    path.addCurve(to: next,
                                control1: CGPoint(x: current.x + (next.x - current.x) / 3, y: current.y),
                                control2: CGPoint(x: current.x + 2 * (next.x - current.x) / 3, y: next.y))
                }
                .stroke(cgPoints[index].isAbove ? AppColors.primaryText.opacity(0.7) : AppColors.accent,
                       style: StrokeStyle(lineWidth: 3, lineCap: .round, lineJoin: .round))
            }
        }
    }
}

struct BarChart: View {
    let data: [DataPoint]
    let max: Double
    let color: Color
    let goal: Double
    let height: CGFloat
    
    var body: some View {
        GeometryReader { geo in
            let spacing = data.count > 0 ? geo.size.width / CGFloat(data.count) : 0
            let barWidth = spacing * 0.6
            
            ForEach(Array(data.enumerated()), id: \.element.id) { index, bar in
                let barHeight = height * (bar.value / max)
                Rectangle()
                    .fill(color.opacity(bar.value > goal ? 0.5 : 1.0))
                    .frame(width: barWidth, height: barHeight)
                    .cornerRadius(4)
                    .position(x: (CGFloat(index) + 0.5) * spacing, y: geo.size.height - barHeight / 2)
            }
        }
    }
}

struct ChartDataSampler {
    static func sample<T: Identifiable>(points: [T], maxPoints: Int) -> [T] {
        guard points.count > maxPoints else { return points }
        let step = max(1, points.count / maxPoints)
        return stride(from: 0, to: points.count, by: step).compactMap { $0 < points.count ? points[$0] : nil }
    }
}

#Preview {
    CalorieTrendChart(
        trendData: TrendData(
            dataPoints: [
                DataPoint(date: .now.addingTimeInterval(-6*86400), value: 1800),
                DataPoint(date: .now.addingTimeInterval(-5*86400), value: 2000),
                DataPoint(date: .now.addingTimeInterval(-4*86400), value: 2200),
                DataPoint(date: .now.addingTimeInterval(-3*86400), value: 1900),
            ],
            goalCalories: 2000
        ),
        period: .weekly
    )
    .frame(height: 200)
    .background(Color.black)
}
#Preview {
    MacroChart(
        title: "Protein",
        data: [
            DataPoint(date: .now, value: 120),
            DataPoint(date: .now.addingTimeInterval(-86400), value: 140),
            DataPoint(date: .now.addingTimeInterval(-2*86400), value: 160)
        ],
        goal: 150,
        color: .blue,
        period: .weekly
    )
    .padding()
    .background(Color.black)
}

