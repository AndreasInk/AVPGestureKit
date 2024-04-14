//
//  MovementDataTests.swift
//  
//
//  Created by Andreas Ink on 4/13/24.
//

import XCTest
import AVPGestureKit

final class MovementDataTests: XCTestCase {

    func test_ReadCount() {
        var readCount = 0
        var data = MovementData(positions: .random, times: .random)
        let positions = data.positions.lazy.map {_ in
            readCount += 1
        }.suffix(10)
        
      
        let randomSIMD = SIMD3<Float>.random(in: 0...2)
        data.addPosition(.random(in: 0...2), atTime: .random(in: 0...4))
        data.addPosition(randomSIMD, atTime: .random(in: 0...4))
        
        XCTAssertEqual(randomSIMD, data.positions.last)
        // Ensure we only have a length of 10
        XCTAssertEqual(data.positions.count, 10)
        // Create an array to have the lazy
        let _ = Array(positions)
        XCTAssertEqual(10, readCount)
    }
}
