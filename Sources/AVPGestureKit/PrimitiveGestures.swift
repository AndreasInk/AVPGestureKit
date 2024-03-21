//
//  PrimitiveGestures.swift
//
//
//  Created by Andreas Ink on 3/20/24.
//

import SwiftUI
import ARKit

struct PrimitiveGestures {
    
    /// Calculates the magnitude (length) of a SIMD3<Float> vector.
    /// - Parameter vector: A SIMD3<Float> vector.
    /// - Returns: The length of the vector.
    static func magnitude(of vector: SIMD3<Float>) -> Float {
        return sqrt((vector.x * vector.x) + (vector.y * vector.y) + (vector.z * vector.z))
    }

    /// Calculates the distance between two points represented as SIMD3<Float>.
    /// - Parameters:
    ///   - from: The starting point as SIMD3<Float>.
    ///   - to: The ending point as SIMD3<Float>.
    /// - Returns: The distance between the two points.
    static func distance(from: SIMD3<Float>, to: SIMD3<Float>) -> Float {
        return magnitude(of: to - from)
    }
    
    /// Checks if a hand anchor represents a fist gesture.
        /// - Parameter handAnchor: The hand anchor data containing joint positions.
        /// - Returns: `true` if the hand anchor represents a fist gesture, `false` otherwise.
    static func isFistGesture(handAnchor: HandAnchor) -> Bool {
        guard let wristPosition = handAnchor.handSkeleton?.joint(.wrist).anchorFromJointTransform.columns.3.xyz else {
            return false
        }
        
        // Define a threshold for how close finger tips should be to the wrist to consider it a fist.
        let fistThreshold: Float = 0.15
        
        // Check each finger tip's distance to the wrist.
        let fingerTips = [HandSkeleton.JointName.thumbTip, .indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip]
        
        for tip in fingerTips {
            guard let tipPosition =  handAnchor.handSkeleton?.joint(tip).anchorFromJointTransform.columns.3.xyz else {
                return false
            }
            
            let distance = simd_distance(wristPosition, tipPosition)
            
            // If any fingertip is further away from the wrist than our threshold, it's not a fist.
            if distance > fistThreshold {
                return false
            }
        }
        
        // If all finger tips are within the threshold distance to the wrist, it's likely a fist.
        return true
    }
    
    static func fistDistance(leftHandAnchor: HandAnchor, rightHandAnchor: HandAnchor) -> Float? {
        guard
            let leftFistCenter = leftHandAnchor.handSkeleton?.joint(.wrist),
            let rightFistCenter = rightHandAnchor.handSkeleton?.joint(.wrist),
            leftFistCenter.isTracked && rightFistCenter.isTracked
        else {
            return nil
        }
        
        let originFromRightHandTransform = matrix_multiply(
            rightHandAnchor.originFromAnchorTransform, rightFistCenter.anchorFromJointTransform
        ).columns.3.xyz
        
        let originFromLeftHandTransform = matrix_multiply(
            leftHandAnchor.originFromAnchorTransform, leftFistCenter.anchorFromJointTransform
        ).columns.3.xyz
        

        // Optionally, check if fists are close together by comparing the distance between the centers.
        let fistsDistance = distance(from: originFromRightHandTransform, to: originFromLeftHandTransform)
        return fistsDistance
    }
    
    static func isThumbsUpGesture(handAnchor: HandAnchor) -> Bool {
        guard let wristPosition = handAnchor.handSkeleton?.joint(.wrist).anchorFromJointTransform.columns.3.xyz else {
            return false
        }
        
        // Define thresholds
        // Decreased threshold for the thumb to be considered 'up'
        let thumbThreshold: Float = 0.05
        // Closer threshold for other fingers to the wrist
        let otherFingersThreshold: Float = 0.15
        
        // Check thumb tip's distance to the wrist, expecting it to be further.
        guard let thumbTipPosition = handAnchor.handSkeleton?.joint(.thumbTip).anchorFromJointTransform.columns.3.xyz else {
            return false
        }
        let thumbDistance = simd_distance(wristPosition, thumbTipPosition)
        if thumbDistance < thumbThreshold {
            return false
        }
        
        // Check each of the other finger tips' distance to the wrist, expecting them to be closer.
        let otherFingerTips: [HandSkeleton.JointName] = [.indexFingerTip, .middleFingerTip, .ringFingerTip, .littleFingerTip]
        
        for tip in otherFingerTips {
            guard let tipPosition = handAnchor.handSkeleton?.joint(tip).anchorFromJointTransform.columns.3.xyz else {
                return false
            }
            
            let distance = simd_distance(wristPosition, tipPosition)
            
            // If any of the other fingertips is further away from the wrist than the closer threshold, it's not a thumbs up.
            if distance > otherFingersThreshold {
                return false
            }
        }
        
        // If the thumb is up and the other fingers are within their closer threshold to the wrist, it's likely a thumbs up.
        return true
    }
    /// Detects shaking motion based on the historical positions and times of a tracked point (e.g., an elbow or hand).
    ///
    /// - Returns:
    ///   * `true` if a shaking motion is detected,
    ///   * `false` otherwise.
    static func detectShakingMotion(handMovement: MovementData) -> Bool {
        
        guard handMovement.positions.count >= 2 else {
            // Not enough data to determine movement.
            return false
        }
        
        // Calculate speed changes between the most recent positions.
        var speedChanges: [Float] = []
        for i in 1..<handMovement.positions.count {
            let distance = simd_distance(handMovement.positions[i], handMovement.positions[i-1])
            let timeDelta = handMovement.times[i] - handMovement.times[i-1]
            
            // Avoid division by zero; continue if timeDelta is very small.
            guard timeDelta > 1e-3 else { continue }
            
            let speed = distance / Float(timeDelta)
            speedChanges.append(speed)
        }
        
        // Detect shaking by analyzing speed changes. Here we look for variability in speed.
        // Define 'shaking' as having a significant number of speed changes above a certain threshold.
        // Adjust based on your observations and requirements.
        let speedVariabilityThreshold: Float = 0.05
        // The count of significant speed changes to consider as shaking.
        let shakingThreshold = 3
        let significantSpeedChanges = speedChanges.filter { abs($0) > speedVariabilityThreshold }.count
        
        return significantSpeedChanges >= shakingThreshold
    }
    
    /// Detects a waving gesture based on the historical positions of a tracked point (e.g., a hand).
    ///
    /// - Returns:
    ///   * `true` if a waving motion is detected,
    ///   * `false` otherwise.
    static func detectWavingMotion(handMovement: MovementData, handAnchor: HandAnchor) -> Bool {
        
      return detectShakingMotion(handMovement: handMovement) && !isFistGesture(handAnchor: handAnchor)
    }

}
