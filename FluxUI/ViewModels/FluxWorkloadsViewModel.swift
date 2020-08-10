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

import Combine
import Foundation
import SwiftUI



class FluxWorkloadsViewModel : ObservableObject {
	
	var fluxSettings: FluxSettings? {
		didSet {
			assert(Thread.isMainThread)
			workloads = .success([])
		}
	}
	
	@Published
	var workloads = Result<[FluxWorkload], Error>.success([])
	
	func load() {
		assert(Thread.isMainThread)
		guard let fluxSettings = fluxSettings else {
			workloads = .failure(SimpleError(message: "No Flux settings."))
			return
		}
		
		loadQueue.async{
			guard !self.isLoading else {return}
			self.isLoading = true
			defer {self.isLoading = false}
			
			do {
				guard let executableURL = Bundle(for: type(of: self)).url(forAuxiliaryExecutable: "fluxctl") else {
					throw SimpleError(message: "Internal error: Cannot find fluxctl, which is annoying because it should be built-in FluxUI!")
				}
				
				let p = Process()
				p.executableURL = executableURL
				// http://flux-vonage-sms-hook.poda.happn.io:3030/api/flux/v6/services?namespace=vonage-sms-hook
				p.arguments = ["--url", fluxSettings.url.absoluteString, "--output-format", "json", "list-workloads", "--namespace", fluxSettings.namespace]
				
				let pipe = Pipe()
				p.standardOutput = pipe
				
				p.launch()
				p.waitUntilExit()
				
				guard let data = try pipe.fileHandleForReading.readToEnd() else {
					throw SimpleError(message: "Did not get any data from fluxctl.")
				}
				let decoded = try JSONDecoder().decode([FluxWorkload].self, from: data)
				DispatchQueue.main.sync{
					self.workloads = .success(decoded)
				}
			} catch {
				DispatchQueue.main.sync{
					self.workloads = .failure(error)
				}
			}
		}
	}
	
	private var isLoading = false
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".workloads-fetch-queue")
	
}
