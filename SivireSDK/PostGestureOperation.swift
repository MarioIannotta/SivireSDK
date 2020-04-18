//
//  PostGestureOperation.swift
//  SivireSDK
//
//  Created by Mario on 18/04/2020.
//  Copyright © 2020 Mario Iannotta. All rights reserved.
//

import Foundation

class PostGestureOperation: Operation {

    enum State: String {
        case ready = "isReady"
        case executing = "isExecuting"
        case finished = "isFinished"
    }

    private var task: URLSessionDataTask?

    override var isAsynchronous: Bool { return true }

    private var state: State = .ready {
        willSet { willChangeValue(forKey: newValue.rawValue) }
        didSet { didChangeValue(forKey: state.rawValue) }
    }

    override var isExecuting: Bool {
        get { state == .executing }
        set { state = .executing }
    }

    override var isFinished: Bool {
        get { state == .finished }
        set { state = .finished }
    }

    override func start() {
        if isCancelled {
            completeOperation()
            return
        }
        isExecuting = true
        task?.resume()
    }

    override func cancel() {
        task?.cancel()
    }

    func completeOperation() {
        isFinished = true
        isExecuting = false
    }

    init?(endpoint: String, gesture: Gesture) {
        guard
            let url = URL(string: endpoint)
            else {
                return nil
            }
        super.init()
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = try? JSONEncoder().encode(gesture)
        request.allHTTPHeaderFields?["Content-Type"] = "application/json"
        print("[SivireSDK] Posting gesture with \(gesture.touches.count) touches")
        task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            self?.completeOperation()
            if (error as NSError?)?.code == -1004 {
                print("[SivireSDK] The local server is down.")
            } else {
                let statusCode = (response as? HTTPURLResponse)?.statusCode ?? -1
                print("[SivireSDK] Gesture posted. Status code: \(statusCode)")
                if statusCode != 200, let data = data {
                    print("[SivireSDK] Response: \(String(data: data, encoding: .utf8) ?? "")")
                }
            }
        }
    }
}
