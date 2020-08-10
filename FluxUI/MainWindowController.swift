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
		let ud = UserDefaults.standard
		let settings = ud.array(forKey: Constants.UserDefaultsKeys.registeredFluxSettings) as? [FluxSettings.UserDefaultRepresentation] ?? []
		let modifiedSettings = NSOrderedSet(array: settings + [FluxSettings(url: URL(string: "http://flux-happn-console.podc.happn.io:3030/api/flux")!, namespace: "happn-console").userDefaultRepresentation]).array
		ud.setValue(modifiedSettings, forKey: Constants.UserDefaultsKeys.registeredFluxSettings)
		ud.setValue(-1, forKey: Constants.UserDefaultsKeys.selectedFluxSettingsIndex) /* This will force selection of the last settings in updateFluxMenu() */
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
