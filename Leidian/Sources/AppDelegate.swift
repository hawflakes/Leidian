//
//  AppDelegate.swift
//  Leidian
//
//  Created by Jack Tihon on 9/24/19.
//  Copyright © 2019 Jack Tihon. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    
    private var count = 0
    private var monitor = PowerMonitor()

    var statusItem:NSStatusItem =  {
        let item = NSStatusBar.system.statusItem(withLength:NSStatusItem.variableLength)
        item.behavior = [.removalAllowed, .terminationOnRemoval]
        if let button = item.button {
            button.font = NSFont.menuFont(ofSize: 10.0)
            button.image = NSImage(imageLiteralResourceName: "Battery Icon Frame")
        } else {
            fatalError("Houston, we have a problem.")
        }
        return item
    }()
    
    var menuButton:NSStatusBarButton? {
        return statusItem.button
    }
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        monitor.delegate = self
        monitor.update()
        monitor.startMonitoring()
        // menus prevent the status action from triggering
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
}

extension AppDelegate: NSMenuDelegate {
    func menuWillOpen(_ menu: NSMenu) {
        monitor.update()
    }
}

extension AppDelegate: PowerMonitorDelegate {
    func powerAdapterUpdated(_ info: ExternalPowerAdapterInfo?) {
        guard let info = info else {
            return
        }
        
        if let watts = info.watts {
            statusItem.button?.title = "\(watts)W"
        }
    }
    
        // build up the menu
        func constructMenu() {
            let menu = NSMenu()
            menu.delegate = self
            
            // TODO: show current power source
            // TODO: show power stats
            menu.addItem(NSMenuItem(title: "Icrement", action: #selector(AppDelegate.incrementMenuItem(_:)), keyEquivalent: "I"))
            menu.addItem(NSMenuItem.separator())
            menu.addItem(NSMenuItem(title: "Quit Quotes", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
            
            statusItem.menu = menu
        }
        
        @objc func incrementMenuItem(_ sender:Any?) {
            // update the button
            guard let button = menuButton else {
                print("Missing menuButton. Is something messed up?")
                return
            }
            

            count += 1
            
            button.title = "\(count)"
            
    //        let baseImage = NSImage(imageLiteralResourceName: "Battery Icon Frame")
    //
    //
    //        button.image = newImage
        }
}
