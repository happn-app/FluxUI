/*
Copyright 2020 happn

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License. */

import AppKit
import Foundation
import os.log
import SwiftUI



/* While we can’t have macOS 11 compatibility, we must use AppKit to setup the
 * toolbar AFAICT 🤷‍♂️ */
class MainWindowController : NSWindowController {
	
	var workloadsModel = FluxWorkloadsViewModel()
	
	var allFluxSettings: [FluxSettings] {
		guard let urls = UserDefaults.standard.array(forKey: Constants.UserDefaultsKeys.registeredFluxSettings) as? [FluxSettings.UserDefaultRepresentation]? else {
			os_log(.error, "Invalid type in user defaults for Flux URLs.")
			return []
		}
		return urls?.compactMap(FluxSettings.init(userDefaultRepresentation:)) ?? []
	}
	
	var selectedFluxSettings: FluxSettings? {
		let settings = allFluxSettings
		let index = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex)
		guard index >= 0 && index < settings.count else {
			os_log(.error, "Invalid selected flux settings index. Returning nil.")
			return nil
		}
		return settings[index]
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		workloadsModel.fluxSettings = selectedFluxSettings
		workloadsModel.load()
		
		let contentView = ContentView(fluxWorkloads: workloadsModel)
		window?.contentView = NSHostingView(rootView: contentView)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		updateFluxMenu()
	}
	
	@IBAction func reloadFluxModel(_ sender: Any) {
		workloadsModel.load()
	}
	
	@IBAction func fluxURLSelected(_ sender: Any) {
		guard let menuItem = sender as? NSMenuItem else {
			os_log(.error, "Invalid sender for fluxURLSelected(_:).")
			return
		}
		
		let index = min(allFluxSettings.count, max(0, menuItem.tag))
		UserDefaults.standard.setValue(index, forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex)
		updateFluxMenu()
		
		workloadsModel.fluxSettings = selectedFluxSettings
		reloadFluxModel(sender)
	}
	
	@IBAction func addFluxURL(_ sender: Any) {
		let newFluxUrlWindow = NSWindow(
			contentRect: NSRect(x: 0, y: 0, width: 480, height: 300),
			styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView],
			backing: .buffered, defer: false
		)
		
		/* Create the SwiftUI view that provides the window contents. */
		let model = NewFluxUrlViewModel()
		let newFluxUrlView = NewFluxUrlView(model: model, action: {
			self.window?.endSheet(newFluxUrlWindow)
			
			guard let url = URL(string: model.url) else {
				NSLog("%@", "Invalid URL given: \(model.url)")
				return
			}
			
			let ud = UserDefaults.standard
			let settings = ud.array(forKey: Constants.UserDefaultsKeys.registeredFluxSettings) as? [FluxSettings.UserDefaultRepresentation] ?? []
			let modifiedSettings = NSOrderedSet(array: settings + [FluxSettings(url: url, namespace: model.namespace).userDefaultRepresentation]).array
			ud.setValue(modifiedSettings, forKey: Constants.UserDefaultsKeys.registeredFluxSettings)
			ud.setValue(-1, forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex) /* This will force selection of the last settings in updateFluxMenu() */
			self.updateFluxMenu()
		})
		
		/* Create the window and set the content view. */
		newFluxUrlWindow.isReleasedWhenClosed = false
		newFluxUrlWindow.contentView = NSHostingView(rootView: newFluxUrlView)
		window?.beginSheet(newFluxUrlWindow, completionHandler: nil)
	}
	
	@IBAction func removeFluxURL(_ sender: Any) {
		let ud = UserDefaults.standard
		
		let index = UserDefaults.standard.integer(forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex)
		var settings = ud.array(forKey: Constants.UserDefaultsKeys.registeredFluxSettings) as? [FluxSettings.UserDefaultRepresentation] ?? []
		guard index >= 0, index < settings.count else {return}
		
		settings.remove(at: index)
		ud.setValue(settings, forKey: Constants.UserDefaultsKeys.registeredFluxSettings)
		ud.setValue(max(index, settings.count-1), forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex)
		
		updateFluxMenu()
	}
	
	private func updateFluxMenu() {
		guard
			let fluxURLsPopUpButton = window?.toolbar?.items.first(where: { $0.itemIdentifier.rawValue == "FluxURLs" })?.view as? NSPopUpButton,
			let fluxURLsMenu = fluxURLsPopUpButton.menu
		else {
			return
		}
		
		fluxURLsMenu.items.filter{ $0.tag >= 0 }.forEach(fluxURLsMenu.removeItem)
		
		for (idx, settings) in allFluxSettings.enumerated().reversed() {
			let menuItem = NSMenuItem(title: settings.namespace + " - " + settings.url.absoluteString, action: #selector(fluxURLSelected(_:)), keyEquivalent: "")
			fluxURLsMenu.insertItem(menuItem, at: 0)
			menuItem.tag = idx
		}
		
		/* Now let’s select the correct Flux URL. */
		let urlItems = fluxURLsMenu.items.filter{ $0.tag >= 0 }
		if !urlItems.isEmpty {
			let ud = UserDefaults.standard
			let index = ud.integer(forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex)
			if index >= 0 && index < urlItems.count {fluxURLsPopUpButton.select(urlItems[index])}
			else                                    {fluxURLSelected(urlItems.last!)}
		} else {
			fluxURLsPopUpButton.selectItem(withTag: -1)
		}
	}
	
}
