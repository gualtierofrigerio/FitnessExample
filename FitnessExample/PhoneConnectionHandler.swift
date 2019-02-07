//
//  PhoneWorkoutManager.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchConnectivity

class PhoneConnectionHandler : NSObject {
    
    var session:WCSession!
    var pendingContext:PhoneWatchSharedData?
    var filePath:String!
    
    override init() {
        super.init()
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        filePath = documentsPath + "/workouts.json"
    }
    
    func initSession(withPendingContext: PhoneWatchSharedData) {
        if WCSession.isSupported() {
            session = WCSession.default
            session.delegate = self
            session.activate()
            pendingContext = withPendingContext
        }
    }
    
    func sendDataToWatch(_ context:PhoneWatchSharedData) {
        if session == nil {
            initSession(withPendingContext: context)
        }
        else {
            sendContext(context)
        }
    }
}

extension PhoneConnectionHandler : PhoneWatchConnection {
    func synchronizeData(_ data:PhoneWatchSharedData) {
        sendDataToWatch(data)
    }
    
    func getUpdatedData(callback: (PhoneWatchSharedData) -> Void) {
        // empty implementation
    }
    
    func getLastData() -> [String : Any] {
        return session.applicationContext
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
