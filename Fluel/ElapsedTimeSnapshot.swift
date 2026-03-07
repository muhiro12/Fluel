//
//  ElapsedTimeSnapshot.swift
//  Fluel
//
//  Created by OpenAI on 2026/03/07.
//

import Foundation

struct ElapsedTimeSnapshot {
    let totalDays: Int
    let totalMonths: Int
    let years: Int
    let months: Int
    let days: Int
    let nextYearMark: Int

    private let remainingMonths: Int
    private let remainingDays: Int

    init(
        startDate: Date,
        referenceDate: Date,
        calendar: Calendar = .autoupdatingCurrent
    ) {
        let clampedReferenceDate = max(referenceDate, startDate)
        let startOfStartDate = calendar.startOfDay(for: startDate)
        let startOfReferenceDate = calendar.startOfDay(for: clampedReferenceDate)

        let elapsedComponents = calendar.dateComponents(
            [.year, .month, .day],
            from: startOfStartDate,
            to: startOfReferenceDate
        )

        years = max(elapsedComponents.year ?? 0, 0)
        months = max(elapsedComponents.month ?? 0, 0)
        days = max(elapsedComponents.day ?? 0, 0)
        totalDays = max(
            calendar.dateComponents(
                [.day],
                from: startOfStartDate,
                to: startOfReferenceDate
            ).day ?? 0,
            0
        )
        totalMonths = max(
            calendar.dateComponents(
                [.month],
                from: startOfStartDate,
                to: startOfReferenceDate
            ).month ?? 0,
            0
        )

        nextYearMark = max(1, years + 1)

        let nextAnniversaryDate = calendar.date(
            byAdding: .year,
            value: nextYearMark,
            to: startOfStartDate
        )
        let nextAnniversaryComponents = nextAnniversaryDate.map {
            calendar.dateComponents([.month, .day], from: startOfReferenceDate, to: $0)
        }

        remainingMonths = max(nextAnniversaryComponents?.month ?? 0, 0)
        remainingDays = max(nextAnniversaryComponents?.day ?? 0, 0)
    }

    var dayHeadline: String {
        "\(totalDays.formatted())日"
    }

    var compactBreakdown: String {
        if years > 0 {
            return "\(years)年 \(months)か月"
        }

        if totalMonths > 0 {
            return joinedDuration(months: months, days: days, fallback: "\(days)日")
        }

        return "\(days)日"
    }

    var fullBreakdown: String {
        if years > 0 {
            return "\(years)年 \(months)か月 \(days)日"
        }

        if totalMonths > 0 {
            return joinedDuration(months: months, days: days, fallback: "\(days)日")
        }

        return "\(days)日"
    }

    var monthSummary: String {
        "\(totalMonths.formatted())か月"
    }

    var nextAnniversarySummary: String {
        let remaining = joinedDuration(
            months: remainingMonths,
            days: remainingDays,
            fallback: "0日"
        )
        return "次の\(nextYearMark)年まであと \(remaining)"
    }

    private func joinedDuration(months: Int, days: Int, fallback: String) -> String {
        let parts = [
            months > 0 ? "\(months)か月" : nil,
            days > 0 ? "\(days)日" : nil
        ]
        .compactMap { $0 }

        return parts.isEmpty ? fallback : parts.joined(separator: " ")
    }
}
