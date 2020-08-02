/*
 * MainWindowController.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

import AppKit
import Foundation
import os.log
import SwiftUI



/* While we can’t have macOS 11 compatibility, we must use AppKit to setup the
 * toolbar AFAICT 🤷‍♂️ */
class MainWindowController : NSWindowController {
	
	var fluxURLs: [String] {
		let ud = UserDefaults.standard
		guard let urls = ud.array(forKey: Constants.UserDefaultsKeys.fluxURLs) as? [String]? else {
			os_log(.error, "Invalid type in user defaults for Flux URLs.")
			return []
		}
		return urls ?? []
	}
	
	var fluxURL: String? {
		let ud = UserDefaults.standard
		guard let urlsOrNil = ud.array(forKey: Constants.UserDefaultsKeys.fluxURLs) as? [String]? else {
			os_log(.error, "Invalid type in user defaults for Flux URLs.")
			return nil
		}
		guard let urls = urlsOrNil else {
			return nil
		}
		let index = ud.integer(forKey: Constants.UserDefaultsKeys.selectedFluxURLIndex)
		guard index >= 0 && index < urls.count else {
			os_log(.error, "Invalid url index for .")
			return nil
		}
		return urls[index]
	}
	
	override func windowDidLoad() {
		super.windowDidLoad()
		
		let model = FluxWorkloadsViewModel(fluxURL: fluxURL ?? "")
		model.load()
		let contentView = ContentView(fluxWorkloads: model)
		window?.contentView = NSHostingView(rootView: contentView)
	}
	
	override func awakeFromNib() {
		super.awakeFromNib()
		
		updateFluxMenu()
	}
	
	@IBAction func reloadFluxModel(_ sender: Any) {
		guard let fluxURL = fluxURL else {return}
		FluxWorkloadsViewModel(fluxURL: fluxURL).load()
	}
	
	@IBAction func fluxURLSelected(_ sender: Any) {
		guard let menuItem = sender as? NSMenuItem else {
			os_log(.error, "Invalid sender for fluxURLSelected(_:).")
			return
		}
		
		let index = fluxURLs.firstIndex{ $0 == menuItem.title }
		if index == nil {
			os_log(.error, "Cannot get index of selected menu item! Selecting first item.")
			return
		}
		let ud = UserDefaults.standard
		ud.setValue(index ?? 0, forKey: Constants.UserDefaultsKeys.selectedFluxURLIndex)
		updateFluxMenu()
		reloadFluxModel(sender)
	}
	
	@IBAction func addFluxURL(_ sender: Any) {
		let ud = UserDefaults.standard
		let urls = ud.array(forKey: Constants.UserDefaultsKeys.fluxURLs) as? [String] ?? []
		let modifiedURLs = NSOrderedSet(array: urls + ["http://flux-happn-console.podc.happn.io:3030/api/flux"]).array
		ud.setValue(modifiedURLs, forKey: Constants.UserDefaultsKeys.fluxURLs)
		ud.setValue(-1, forKey: Constants.UserDefaultsKeys.selectedFluxURLIndex) /* This will force selection of the last URL in updateFluxMenu() */
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
		
		let ud = UserDefaults.standard
		
		for url in fluxURLs.reversed() {
			fluxURLsMenu.insertItem(withTitle: url, action: #selector(fluxURLSelected(_:)), keyEquivalent: "", at: 0)
		}
		
		/* Now let’s select the correct Flux URL. */
		let urlItems = fluxURLsMenu.items.filter{ $0.tag >= 0 }
		if !urlItems.isEmpty {
			let index = ud.integer(forKey: Constants.UserDefaultsKeys.selectedFluxURLIndex)
			if index >= 0 && index < urlItems.count {fluxURLsPopUpButton.select(urlItems[index])}
			else                                    {fluxURLSelected(urlItems.last!)}
		} else {
			fluxURLsPopUpButton.selectItem(withTag: -1)
		}
	}
	
}
