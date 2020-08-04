/*
 * AppDelegate.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Cocoa
import Foundation

import XibLoc



@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		XibLocConfig.defaultPluralityDefinition = PluralityDefinition(string: NSLocalizedString("plurality definition", value: "(1)(*)", comment: "Plurality definition for XibLoc. See XibLoc doc for more info."))
		
		/* Set some PATH vars. But after all we’re not doing that! The Sandbox and
		 * hardened runtime make it a bit more difficult to access stuff, so we’ll
		 * simply embed fluxctl in the app… */
//		let homePath = FileManager.default.homeDirectoryForCurrentUser.path
//		let currentPath = getenv("PATH").flatMap{ String(cString: $0) } ?? ""
//		setenv("PATH", currentPath + (!currentPath.isEmpty ? ":" : "") + "/usr/local/bin:" + homePath + "/usr/homebrew/bin", 1)
		
//		do {
//			let images = try JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "images", withExtension: "json")!))
//			let workloads = try JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "workloads", withExtension: "json")!))
//		} catch {
//			print(error)
//		}
	}
	
	func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
		return true
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
	}
	
}
