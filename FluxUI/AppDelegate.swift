/*
 * AppDelegate.swift
 * FluxUI
 *
 * Created by François Lamboley on 01/08/2020.
 */

import Cocoa

import XibLoc



@main
class AppDelegate: NSObject, NSApplicationDelegate {
	
	func applicationDidFinishLaunching(_ aNotification: Notification) {
		XibLocConfig.defaultPluralityDefinition = PluralityDefinition(string: NSLocalizedString("plurality definition", value: "(1)(*)", comment: "Plurality definition for XibLoc. See XibLoc doc for more info."))
		
//		do {
//			let images = try JSONDecoder().decode([FluxImage].self, from: Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "images", withExtension: "json")!))
//			let workloads = try JSONDecoder().decode([FluxWorkload].self, from: Data(contentsOf: Bundle(for: type(of: self)).url(forResource: "workloads", withExtension: "json")!))
//		} catch {
//			print(error)
//		}
	}
	
	func applicationWillTerminate(_ aNotification: Notification) {
	}
	
}
