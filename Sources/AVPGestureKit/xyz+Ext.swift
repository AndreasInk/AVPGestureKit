//
//  xyz+Ext.swift
//
//
//  Created by Andreas Ink on 3/20/24.
//

import simd

extension SIMD4 {
    var xyz: SIMD3<Scalar> {
        self[SIMD3(0, 1, 2)]
    }
}
