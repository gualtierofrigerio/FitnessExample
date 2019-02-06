//
//  WatchWorkoutManager.swift
//  FitnessExample WatchKit Extension
//
//  Created by Gualtiero Frigerio on 05/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import WatchConnectivity

class WatchConnectionHandler : NSObject {
    
    let session = WCSession.default
    var updateCallback:(([String:Any]) ->Void)?
    
    override init() {
        super.init()
        session.delegate = self
        session.activate()
    }
}

extension WatchConnectionHandler : PhoneWatchConnection {

    func synchronizeData(_ data: [String : Any]) {
        
    }
    
    func getLastData() -> [String : Any] {
        return session.applicationContext
    }
    
    func getUpdatedData(callback: @escaping ([String : Any]) -> Void) {
        updateCallback = callback
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
