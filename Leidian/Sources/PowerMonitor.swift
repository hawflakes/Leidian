//
//  PowerMonitor.swift
//  Leidian
//
//  Created by Jack Tihon on 10/1/19.
//  Copyright © 2019 Jack Tihon. All rights reserved.
//

import Foundation
import IOKit

protocol PowerMonitorDelegate: class {
    func powerAdapterUpdated(_ info:ExternalPowerAdapterInfo?)
}

class PowerMonitor {
    
    weak var delegate:PowerMonitorDelegate? = nil
    
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
           
            // TODO: update with the right source
            guard let context = context else {
                return
            }
            
            let contextSelf = Unmanaged<PowerMonitor>.fromOpaque(context).takeUnretainedValue()
            
            if let delegate = contextSelf.delegate {
                if let externalDetails = IOPSCopyExternalPowerAdapterDetails(),
                    let externalDetailsDict = externalDetails.takeUnretainedValue() as? [String:Any] {
                    let info = ExternalPowerAdapterInfo(externalDetailsDict)
                    delegate.powerAdapterUpdated(info)
                } else {
                    delegate.powerAdapterUpdated(nil)
                }
            }
            
        }, context)
        self.runloopSource = source
        
        let current = RunLoop.current
        CFRunLoopAddSource(current.getCFRunLoop(),
                           source.takeUnretainedValue(),
                           CFRunLoopMode.defaultMode)
        
// NOTE: IOPSCreateLimitedPowerNotification() is superceded by the above IOPSNotificationCreateRunLoopSource()
// IOPSCreateLimitedPowerNotification(<#T##callback: IOPowerSourceCallbackType!##IOPowerSourceCallbackType!##(UnsafeMutableRawPointer?) -> Void#>, <#T##context: UnsafeMutableRawPointer!##UnsafeMutableRawPointer!#>)

        
    }
    
    func stopMonitoring() {

    }
   
    func update() {
        self.updateSources()
        self.updatePowerAdapter()
    }
    
    /*
     fetch the current power state
     */
    func updateSources() {
        let powerSourcesInfo = IOPSCopyPowerSourcesInfo().takeRetainedValue()
        let powerSources = IOPSCopyPowerSourcesList(powerSourcesInfo).takeRetainedValue() as [CFTypeRef]
        
        for rawSource in powerSources {
            if let sourceDescription = IOPSGetPowerSourceDescription(powerSourcesInfo, rawSource).takeUnretainedValue() as? [String:Any] {
                print("\n=======================\n")
                print(sourceDescription)
                print("=======================\n")
            } else {
                print("Couldn't get description for source")
            }
        }
    }
  
    // get stats on the power adapter
    func updatePowerAdapter() {
        guard let details = IOPSCopyExternalPowerAdapterDetails()  else  {
            return
        }
        let powerAdapterInfo = details.takeUnretainedValue()
        print("power adapter info: \(powerAdapterInfo)")

//            /// kIOPSPowerSourceStateKey values
//            kIOPSOffLineValue
//            kIOPSACPowerValue
//            kIOPSBatteryPowerValue
//
//           /// kIOPSTransportTypeKey values
//            kIOPSSerialTransportType
//            kIOPSUSBTransportType
//            kIOPSNetworkTransportType
//            kIOPSInternalType
        if let d = powerAdapterInfo as? [String:Any] {
            let info = ExternalPowerAdapterInfo(d)
            delegate?.powerAdapterUpdated(info)
            print(info)
        } else {
            delegate?.powerAdapterUpdated(nil)
        }
    }
}


// Power Adapter Information
struct ExternalPowerAdapterInfo {
    var id:Int?
    var revision:Int?
    var serialNumber:Int?
    var family:Int?
    
    var current:Int? //mAmps
    var watts:Int?
    var source:Int? // what is this?
    
    init(_ info:[String:Any]) {
        /// IOPSPowerAdapter keys
        /// All _optional_
        /// If present, kCFNumberIntType type
        //            kIOPSPowerAdapterIDKey
        //            kIOPSPowerAdapterWattsKey
        //            kIOPSPowerAdapterRevisionKey
        //            kIOPSPowerAdapterSerialNumberKey
        //            kIOPSPowerAdapterFamilyKey
        //            kIOPSPowerAdapterCurrentKey // mAmps
        //            kIOPSPowerAdapterSourceKey
        
        id = info[kIOPSPowerAdapterIDKey] as? Int
        revision = info[kIOPSPowerAdapterRevisionKey] as? Int
        serialNumber = info[kIOPSPowerAdapterSerialNumberKey] as? Int
        family = info[kIOPSPowerAdapterFamilyKey] as? Int
        
        watts = info[kIOPSPowerAdapterWattsKey] as? Int
        current = info[kIOPSPowerAdapterCurrentKey] as? Int // mAmps
        source = info[kIOPSPowerAdapterSourceKey] as? Int
    }
    
}

extension ExternalPowerAdapterInfo: CustomDebugStringConvertible {
    var debugDescription: String {
        return """
        External Power Source:
        id: \(id != nil ? "\(id)": "nil")
        revision: \(revision != nil ? "\(revision)": "nil")
        serialNumber: \(serialNumber != nil ? "\(serialNumber)": "nil")
        family: \(family != nil ? "\(family)": "nil")
        current: \(current != nil ? "\(family)": "nil")
        watts: \(watts != nil ? "\(watts)": "nil")
        source: \(source != nil ? "\(source)": "nil")
        """
    }
}


struct BatteryPowerInfo {
    
}
