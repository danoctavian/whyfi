//
//  main.swift
//  whyfi
//
//  Created by Dan Cristian Octavian on 7/9/16.
//  Copyright © 2016 Dan Cristian Octavian. All rights reserved.
//

import Foundation
import CoreWLAN
import SystemConfiguration


/*
    loop
        ping regularly. if ping doesn't work for a few attempts,
        see what network you're currently connected to, disconnect and reconnect.

*/

func reconnect() {
    if let currentInterface = CWWiFiClient.sharedWiFiClient().interface(),
        currentNetwork = getCurrentNetwork(currentInterface) {
            print("disconnecting from network \(currentNetwork.ssid!)..")
            currentInterface.disassociate()
            print("reconnecting to network \(currentNetwork.ssid!)..")
            do {
               try currentInterface.associateToNetwork(currentNetwork, password: "soler4575")
            } catch let err as NSError {
                print("failed to reconnect: " + err.localizedDescription)
            }
            
    } else {
        print("failed to get default interface")
    }
}

func getCurrentNetwork(interface: CWInterface) -> CWNetwork? {
    let currentSSID = interface.ssid()
    if let cached = interface.cachedScanResults() {
        for network in cached {
            if (network.ssid! == currentSSID) {
                return network
            }
        }
    }
    return nil
}

func shell(args: String...) -> Int32 {
    let task = NSTask()
    task.launchPath = "/usr/bin/env"
    task.arguments = args
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

print("whyfi?!? started")


var failedConsecutivePings = 0

while true {
    let returnCode = shell("ping", "-c 1", "-W 1000", "8.8.8.8")
    if returnCode == 0 {
        print("Network is reachable.")
        failedConsecutivePings = 0
        sleep(1)
    } else {
        print("ERROR: Network is unreachable.")
        failedConsecutivePings++
        if (failedConsecutivePings > 4) {
            print("Attempting reconnect.")
            reconnect()
        } else {
            sleep(1)
        }
    }
}


