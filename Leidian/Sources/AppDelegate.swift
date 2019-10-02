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

    let statusItem:NSStatusItem =  {
        let item = NSStatusBar.system.statusItem(withLength:NSStatusItem.squareLength)
        if let button = item.button {
            button.font = NSFont.systemFont(ofSize: NSStatusItem.squareLength, weight: .medium)
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
        if let button = statusItem.button {
          button.action = #selector(menuTapped(_:))
        }
        monitor.update()
        monitor.startMonitoring()
        constructMenu()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

    @objc func menuTapped(_ sender:Any?) {
        print("menu tapped")
        monitor.update()
    }

    // build up the menu
    func constructMenu() {
        let menu = NSMenu()
        
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

