//
//  xyz+Ext.swift
//
//
//  Created by Andreas Ink on 3/20/24.
//

import simd
import Foundation

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}

extension ArraySlice where Element == SIMD3<Float> {
    public static var random: Self {
        var result = [SIMD3<Float>]()
        for _ in 0...10 {
            let x = Float.random(in: -2...2)
            let y = Float.random(in: -2...2)
            let z = Float.random(in: -2...2)
            result.append(SIMD3(x: x, y: y, z: z))
        }
        return ArraySlice(result)
    }
}

extension ArraySlice where Element == TimeInterval {
    public static var random: Self {
        return ArraySlice((0...10).map { _ in TimeInterval.random(in: 0...2) })
    }
}
