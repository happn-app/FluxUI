/*
 * MainWindowController.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import AppKit
import Foundation
import SwiftUI



/* While we can’t have macOS 11 compatibility, we must use AppKit to setup the
 * toolbar AFAICT 🤷‍♂️ */
class MainWindowController : NSWindowController {
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		let contentView = ContentView(fluxWorkloads: [])
		print(type(of: contentView.body))
		window?.contentView = NSHostingView(rootView: contentView)
	}
	
}
