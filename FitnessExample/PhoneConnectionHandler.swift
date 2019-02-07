//
//  PhoneWorkoutManager.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchConnectivity

class PhoneConnectionHandler : PhoneWatchConnectionHandler {
    
    var filePath:String!
    
    override init() {
        super.init()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        filePath = documentsPath + "/workouts.json"
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

// MARK: - WCSessionDelegate

extension PhoneConnectionHandler : WCSessionDelegate {
    func session(_ session: WCSession, activationDidCompleteWith activationState: WCSessionActivationState, error: Error?) {
        if activationState == .activated {
            print("activationDidComplete on iPhone")
            if let context = pendingContext {
                sendContext(context)
                pendingContext = nil
            }
        }
    }
    
    func sessionDidBecomeInactive(_ session: WCSession) {
        print("sessionDidBecomeInactive on iPhone")
    }
    
    func sessionDidDeactivate(_ session: WCSession) {
        print("sessionDidDeactivate on iPhone")
    }
    
    func session(_ session: WCSession, didReceiveApplicationContext applicationContext: [String : Any]) {
        print("didReceiveApplicationContext on iPhone")
        if let callback = updateCallback {
            callback(applicationContext)
        }
    }
}

// MARK: - Private functions

extension PhoneConnectionHandler {
    private func sendContext(_ context:[String:Any]) {
        do {
            try session?.updateApplicationContext(context)
        }
        catch {
            print("error while setting application context")
        }
    }
}

