//
//  GestureViewModel.swift
//
//
//  Created by Andreas Ink on 3/20/24.
//

import SwiftUI
import ARKit

// If not main actor, the task fails to start
@MainActor
public class GestureViewModel: ObservableObject {
    
    public init() {}
    
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
        if isReadyToRun {
            await session.requestAuthorization(for: [.handTracking])
            // Ensure this is called prior to starting to prevent any tracking issues
            stop()
            do {
                try await session.run([handTracking])
            } catch {
                print(error)
            }
            Task {
                await processHandTrackingUpdates()
            }
        } else {
            await start()
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
        guard let left = latestHandTracking.left, let right = latestHandTracking.right else {
            print("no updates")
            return
        }
        if PrimitiveGestures.isThumbsUpGesture(handAnchor: left) {
            print("Left thumbs up")
        }
        if PrimitiveGestures.isThumbsUpGesture(handAnchor: right) {
            print("Right thumbs up")
        }
        
        if PrimitiveGestures.isFistGesture(handAnchor: left) {
            print("Left fist clench")
        }
        if PrimitiveGestures.isFistGesture(handAnchor: right) {
            print("Right fist clench")
        }
        
        if PrimitiveGestures.detectWavingMotion(handMovement: leftHandMovement) {
            print("Left waving")
        }
        
        if PrimitiveGestures.detectWavingMotion(handMovement: rightHandMovement) {
            print("right waving")
        }
        
        if PrimitiveGestures.detectShakingMotion(handMovement: leftHandMovement) {
            print("Left shaking")
        }
        
        if PrimitiveGestures.detectShakingMotion(handMovement: rightHandMovement) {
            print("right shaking")
        }
    }
}
