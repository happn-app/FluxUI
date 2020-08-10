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
