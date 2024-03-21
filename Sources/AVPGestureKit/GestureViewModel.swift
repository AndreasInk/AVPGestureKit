//
//  GestureViewModel.swift
//
//
//  Created by Andreas Ink on 3/20/24.
//

import SwiftUI
import ARKit

public enum GestureState {
    case thumbsUp
    case thumbsDown
    
    case wave
    
    case none
    
    public var emoji: String {
        switch self {
        case .thumbsUp:
            return "👍"
        case .thumbsDown:
            return ""
        case .wave:
            return "👋"
        case .none:
            return ""
        }
    }
}

// If not main actor, the task fails to start
@MainActor
public class GestureViewModel: ObservableObject {
    
    public init() {}
    
    @Published public var state = GestureState.none
    struct HandsUpdates {
        var left: HandAnchor?
        var right: HandAnchor?
    }
    
    // Tracks hands
    let session = ARKitSession()
    let handTracking = HandTrackingProvider()
    
    // Handles hand movement
    var leftHandMovement = MovementData(positions: [], times: [])
    var rightHandMovement = MovementData(positions: [], times: [])
    var latestHandTracking: HandsUpdates = .init(left: nil, right: nil)
        
    var isReadyToRun: Bool {
        handTracking.state == .initialized 
    }
    
    // Starts the hand tracking
    public func start() async {
        await session.requestAuthorization(for: [.handTracking])

        do {
            try await session.run([handTracking])
        } catch {
            print(error)
        }
        Task {
            await processHandTrackingUpdates()
        }
    }

    // Stops the session
    public func stop() {
        session.stop()
    }
    
    // Updates hand tracking as the system gives us data
    func processHandTrackingUpdates() async {
        for await update in handTracking.anchorUpdates {
            switch update.event {
            case .updated:
                let now = CACurrentMediaTime()
                let anchor = update.anchor
                // Update left hand info.
                if anchor.chirality == .left {
                    latestHandTracking.left = anchor
                    leftHandMovement.addPosition(anchor.originFromAnchorTransform.columns.3.xyz, atTime: now)
                    
                    // Update right hand info.
                } else if anchor.chirality == .right {
                    latestHandTracking.right = anchor
                    rightHandMovement.addPosition(anchor.originFromAnchorTransform.columns.3.xyz, atTime: Date.now.timeIntervalSince1970)
                }
            default:
                break
            }
            checkForGestures()
        }
    }
    
    // Prints if our gestures are occurring now
    func checkForGestures() {
        guard let left = latestHandTracking.left, let right = latestHandTracking.right, left.isTracked else {
            print("no updates or left hand isn't tracked")
            return
        }
        if PrimitiveGestures.isThumbsUpGesture(handAnchor: left) {
            print("Left thumbs up")
            updateState(.thumbsUp)
        }
        if PrimitiveGestures.isThumbsUpGesture(handAnchor: right) {
            print("Right thumbs up")
            updateState(.thumbsUp)
        }
        
        if PrimitiveGestures.isFistGesture(handAnchor: left) {
            print("Left fist clench")
        }
        if PrimitiveGestures.isFistGesture(handAnchor: right) {
            print("Right fist clench")
        }
        
        if PrimitiveGestures.detectWavingMotion(handMovement: leftHandMovement, handAnchor: left) {
            print("Left waving")
            updateState(.wave)
        }
        
        if PrimitiveGestures.detectWavingMotion(handMovement: rightHandMovement, handAnchor: right) {
            print("Right waving")
            updateState(.wave)
        }
        
        if PrimitiveGestures.detectShakingMotion(handMovement: leftHandMovement) {
            print("Left shaking")
        }
        
        if PrimitiveGestures.detectShakingMotion(handMovement: rightHandMovement) {
            print("right shaking")
        }
        
    }
    
    func updateState(_ state: GestureState) {
        self.state = state
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            self.state = .none
        }
    }
}
