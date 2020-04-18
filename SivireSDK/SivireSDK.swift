//
//  SivireSDK.swift
//  SivireSDK
//
//  Created by Mario on 17/04/2020.
//  Copyright © 2020 Mario Iannotta. All rights reserved.
//

import UIKit

struct Touch: Encodable {

    struct Location: Encodable {
        let x: Float
        let y: Float
    }

    private static let bootTime = Date(timeIntervalSinceNow: -ProcessInfo.processInfo.systemUptime)

    let timestamp: TimeInterval
    let location: Location

    init(touch: UITouch) {
        let rawLocation = touch.location(in: touch.window)
        self.location = Location(x: Float(rawLocation.x), y: Float(rawLocation.y))
        timestamp = Date(timeInterval: touch.timestamp, since: Self.bootTime).timeIntervalSince1970
    }
}

struct Gesture: Encodable {
    let touches: [Touch]
}

public class SivireSDK {

    @objc
    public static func configure(port: String) {
        endpoint = "http://localhost:\(port)/gesture"
        UIApplication.shared.swizzle()
    }

    private static let queue: OperationQueue = {
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 4
        queue.qualityOfService = .userInitiated
        return queue
    }()

    private static var endpoint = ""
    private static var gestures = [Gesture]()
    private static var currentTouches = [Touch]()

    fileprivate static func handleEvent(_ event: UIEvent) {
        let touches = event.allTouches ?? []
        currentTouches += touches.map(Touch.init)
        let phase = touches.first?.phase
        if phase == .ended || phase == .cancelled {
            let gesture = Gesture(touches: currentTouches)
            postGesture(gesture)
            currentTouches = []
        }
    }

    private static func postGesture(_ gesture: Gesture) {
        guard
            let operation = PostGestureOperation(endpoint: endpoint, gesture: gesture)
            else { return }
        queue.addOperation(operation)
    }
}


extension UIApplication {

    public func swizzle() {
        guard
            let originalMethod = class_getInstanceMethod(object_getClass(self), #selector(UIApplication.sendEvent(_:))),
            let swizzledMethod = class_getInstanceMethod(object_getClass(self), #selector(UIApplication.swizzledSendEvent(_:)))
            else { return }
        method_exchangeImplementations(originalMethod, swizzledMethod)
    }

    @objc public func swizzledSendEvent(_ event: UIEvent) {
        SivireSDK.handleEvent(event)
        swizzledSendEvent(event)
    }
}
