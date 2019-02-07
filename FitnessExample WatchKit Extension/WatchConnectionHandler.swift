//
//  WatchWorkoutManager.swift
//  FitnessExample WatchKit Extension
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchConnectivity

class WatchConnectionHandler : PhoneWatchConnectionHandler {
    
    override init() {
        super.init()
        initSession(withPendingContext: nil)
    }
    
    override func initSession(withPendingContext: PhoneWatchSharedData?) {
        if WCSession.isSupported() {
            session = WCSession.default
            session!.delegate = self
            session!.activate()
            pendingContext = withPendingContext
        }
    }
}

extension WatchConnectionHandler :  WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        print("activationDidComplete on Watch")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext on Watch")
        if let callback = updateCallback {
            callback(applicationContext)
        }
    }
}
