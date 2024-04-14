//
//  MovementData.swift
//  
//
//  Created by Andreas Ink on 3/20/24.
//

import SwiftUI
import Algorithms

public struct MovementData {
    // Stores recent positions of a joint
    public var positions: ArraySlice<SIMD3<Float>>
    // Corresponding timestamps for each position.
    public var times: ArraySlice<TimeInterval>
    
    public init(positions: ArraySlice<SIMD3<Float>>, times: ArraySlice<TimeInterval>) {
        self.positions = positions
        self.times = times
    }
    /// Adds a new position and its timestamp to the tracking data, ensuring the arrays don't exceed a maximum size.
    mutating public func addPosition(_ position: SIMD3<Float>, atTime time: TimeInterval) {
        positions.append(position)
        times.append(time)
        
        positions = positions.suffix(30)
        times = times.suffix(30)
    }
}
