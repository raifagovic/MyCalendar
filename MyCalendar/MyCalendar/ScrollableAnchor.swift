
//
//  ScrollableAnchor.swift
//  MyCalendar
//
//  Created by Raif Agovic on 5. 8. 2025..
//

import Foundation

// This enum gives us a type-safe way to handle different scroll targets.
enum ScrollableAnchor: Hashable {
    case month(Date)      // Used for the header update PreferenceKey
    case todayTarget      // A single, unique ID for the "Today" button to find
}
