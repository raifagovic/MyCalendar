//
//  VisibleMonthPreferenceKey.swift
//  MyCalendar
//
//  Created by Raif Agovic on 9. 8. 2025..
//

import SwiftUI

// This PreferenceKey will collect the frames of all visible months.
struct VisibleMonthPreferenceKey: PreferenceKey {
    // The data we will collect is a dictionary of [Month Date : Frame]
    typealias Value = [Date: CGRect]

    // A default value must be provided.
    static var defaultValue: Value = [:]

    // This function combines the values from multiple child views.
    // We simply merge the dictionaries.
    static func reduce(value: inout Value, nextValue: () -> Value) {
        value.merge(nextValue()) { $1 }
    }
}
