//
//  PowerMonitor.swift
//  Leidian
//
//  Created by Jack Tihon on 10/1/19.
//  Copyright © 2019 Jack Tihon. All rights reserved.
//

import Foundation
import IOKit


class PowerMonitor {
    
    init() {
        
    }
    
    var runloopSource:Unmanaged<CFRunLoopSource>?
    
    func startMonitoring() {
        // NOTE: Following Conventions for Unmanaged memory:
        // `takeUnretainedValue()` for `Create*` functions
        // `takeRetainedvalue()` for `Get*` functions
        // https://nshipster.com/unmanaged/
        
        // TODO: put this into a different thread/runLoop
        // start listening in a runloop
        let context = UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
        let source:Unmanaged<CFRunLoopSource> = IOPSNotificationCreateRunLoopSource({ (context) in
            let powerSourcesInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
            let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo).takeRetainedValue() as [CFTypeRef]

            for rawSource in powerSources {
                if let sourceDescription = IOPSGetPowerSourceDescription(powerSourcesInfo, rawSource).takeUnretainedValue() as? [String:Any] {
                    print(sourceDescription)
                    print("\n")
                } else {
                    print("Couldn't get description for source")
                }
            }
        }, context)
        self.runloopSource = source
        
        let current = RunLoop.current
        CFRunLoopAddSource(current.getCFRunLoop(),
                           source.takeUnretainedValue(),
                           CFRunLoopMode.defaultMode)
    }
    
    func stopMonitoring() {

    }
   
    /*
     fetch the current power state
     */
    func update() {
        let powerSourcesInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo).takeRetainedValue() as [CFTypeRef]
        
        for rawSource in powerSources {
            if let sourceDescription = IOPSGetPowerSourceDescription(powerSourcesInfo, rawSource).takeUnretainedValue() as? [String:Any] {
                print(sourceDescription)
                print("\n")
            } else {
                print("Couldn't get description for source")
            }
        }
    }
}
