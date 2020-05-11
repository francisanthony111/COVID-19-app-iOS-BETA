//
//  StatusStateMachineMigration.swift
//  Sonar
//
//  Created by NHSX.
//  Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

class StatusStateMachineMigration {

    private let dateProvider: () -> Date

    private var currentDate: Date { dateProvider() }

    init(dateProvider: @escaping () -> Date = { Date() }) {
        self.dateProvider = dateProvider
    }

    func migrate(
        diagnosis: SelfDiagnosis?,
        potentiallyExposedOn: Date?
    ) -> StatusState {
        switch (diagnosis, potentiallyExposedOn) {
        case (.none, .none):
            return .ok
        case (.none, .some(let date)):
            // This should never happen, but date types, right?
            guard let delta = daysSince(date) else {
                return .ok
            }

            // If it's been 14 days, you're ok again
            guard delta < 14 else {
                return .ok
            }

            return .exposed(on: date)
        case (.some(let diagnosis), _):
            guard !diagnosis.symptoms.isEmpty else {
                return .ok
            }

            if currentDate > diagnosis.expiryDate || diagnosis.type == .subsequent {
                let startOfDay = Calendar.current.startOfDay(for: currentDate)
                let checkinDate = Calendar.current.nextDate(
                    after: startOfDay,
                    matching: DateComponents(hour: 7),
                    matchingPolicy: .nextTime
                )!
                return .checkin(symptoms: diagnosis.symptoms, at: checkinDate)
            } else {
                return .symptomatic(
                    symptoms: diagnosis.symptoms,
                    expires: diagnosis.expiryDate
                )
            }
        }
    }

    private func daysSince(_ date: Date) -> Int? {
        let dateComponents = Calendar.current.dateComponents(
            [.day],
            from: date,
            to: currentDate
        )
        return dateComponents.day
    }


}
