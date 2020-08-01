/*
 * AppDelegate.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Cocoa
import SwiftUI

import XibLoc



@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	var window: NSWindow!
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		XibLocConfig.defaultPluralityDefinition = PluralityDefinition(string: NSLocalizedString("plurality definition", value: "(1)(*)", comment: "Plurality definition for XibLoc. See XibLoc doc for more info."))
		
		/* Create the SwiftUI view that provides the window contents. */
		let contentView = ContentView()
		
		/* Create the window and set the content view. */
		window = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false
		)
		window.isReleasedWhenClosed = false
		window.center()
		window.setFrameAutosaveName("Main Window")
		window.contentView = NSHostingView(rootView: contentView)
		window.makeKeyAndOrderFront(nil)
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
		// Insert code here to tear down your application
	}
	
}
