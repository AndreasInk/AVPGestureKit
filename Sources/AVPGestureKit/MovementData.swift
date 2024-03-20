//
//  MovementData.swift
//  
//
//  Created by Andreas Ink on 3/20/24.
//

import SwiftUI

struct MovementData {
    // Stores recent positions of a joint
    var positions: [SIMD3<Float>]
    // Corresponding timestamps for each position.
    var times: [TimeInterval]

    /// Adds a new position and its timestamp to the tracking data, ensuring the arrays don't exceed a maximum size.
    mutating func addPosition(_ position: SIMD3<Float>, atTime time: TimeInterval) {
        positions.append(position)
        times.append(time)
        
        // Keep the arrays to a maximum size to only consider recent movement.
        let maxSize = 10
        if positions.count > maxSize {
            positions.removeFirst(positions.count - maxSize)
            times.removeFirst(times.count - maxSize)
        }
    }
}
