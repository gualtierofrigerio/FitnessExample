//
//  PhoneWatchConnection.swift
//  FitnessExample
//
//  Created by Gualtiero Frigerio on 06/02/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

/*
 Defines the common functions for Phone and Watch connection handlers
 synchronizeData and getLastData are mandatory as we send data back and forth from the Watch
 while getUpdatedData is optional as we can provide an empty implementation and allows
 for the caller to be notified every time new data is send through the common session
 */

protocol PhoneWatchConnection {
    func synchronizeData(_ data:[String:Any])
    func getLastData() -> [String:Any]
    func getUpdatedData(callback: @escaping([String:Any]) ->Void)
}
