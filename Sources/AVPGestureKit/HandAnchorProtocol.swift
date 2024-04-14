//
//  HandAnchorProtocol.swift
//
//
//  Created by Andreas Ink on 4/13/24.
//

import ARKit
import simd

/// Protocol defining the requirements for a HandAnchor in an ARKit session.
protocol HandAnchorProtocol: CustomStringConvertible, Identifiable, Sendable {
    /// The unique identifier of this hand anchor.
    var id: UUID { get }

    /// The transform from the hand's wrist to the origin coordinate system.
    var originFromAnchorTransform: simd_float4x4 { get }

    /// The skeleton of this hand.
    var handSkeleton: HandSkeleton? { get }

    /// The chirality (left or right hand) of this hand anchor.
    var chirality: HandAnchor.Chirality { get }

    /// Indicates whether this hand anchor is currently tracked.
    var isTracked: Bool { get }
}

extension HandAnchorProtocol {
    /// Textual description for logging or debugging purposes.
    var description: String {
        "HandAnchor(id: \(id), chirality: \(chirality), isTracked: \(isTracked))"
    }
}

/// Protocol for hand skeletons used in ARKit sessions.
protocol HandSkeletonProtocol: CustomStringConvertible, Sendable {
    /// Provides the skeleton of a hand in a neutral pose.
    static func neutralPose() -> Self

    /// Retrieves the joint of a given name.
    func joint(named: HandSkeleton.JointName) -> HandSkeleton.Joint

    /// All joints of this skeleton.
    var allJoints: [HandSkeleton.Joint] { get }

    /// A textual representation of this skeleton.
    var description: String { get }
}

/// Joint structure within a hand skeleton.
protocol JointProtocol: CustomStringConvertible, Sendable {
    var parentJoint: Self? { get }
    var name: HandSkeleton.JointName { get }
    var parentFromJointTransform: simd_float4x4 { get }
    var anchorFromJointTransform: simd_float4x4 { get }
    var isTracked: Bool { get }
}

/// Defines chirality (left or right orientation) for hands.
protocol ChiralityProtocol: CustomStringConvertible, Sendable {
    var chirality: HandSkeleton.Chirality { get }
}

/// Implementing the actual structures conforming to these protocols.
extension HandSkeleton: HandSkeletonProtocol {
    typealias Joint = HandSkeleton.Joint
    typealias Chirality = HandAnchor.Chirality

    static func neutralPose() -> HandSkeleton {
        return .neutralPose
    }

    func joint(named: JointName) -> HandSkeleton.Joint {
        return joint(named)
    }
}

extension HandAnchor: HandAnchorProtocol {
    
}
