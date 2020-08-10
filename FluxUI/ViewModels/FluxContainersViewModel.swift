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



class FluxContainersViewModel : ObservableObject {
	
	var fluxSettings: FluxSettings? {
		didSet {
			assert(Thread.isMainThread)
			containers = .success([])
		}
	}
	
	var workloadID: String {
		didSet {
			assert(Thread.isMainThread)
			containers = .success([])
		}
	}
	
	@Published
	var containers = Result<[FluxContainer], Error>.success([])
	
	init(fluxSettings: FluxSettings? = nil, workloadID: String) {
		self.fluxSettings = fluxSettings
		self.workloadID = workloadID
	}
	
	func load() {
		assert(Thread.isMainThread)
		
		guard let fluxSettings = fluxSettings else {
			containers = .failure(SimpleError(message: "No Flux settings."))
			return
		}
		let workloadID = self.workloadID
		
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
				// http://flux-vonage-sms-hook.poda.happn.io:3030/api/flux/v10/images?containerFields=&namespace=&service=vonage-sms-hook%3Adeployment%2Fflux
				p.arguments = ["--url", fluxSettings.url.absoluteString, "--output-format", "json", "list-images", "--limit", "0", "--namespace", fluxSettings.namespace, "--workload", workloadID]
				
				let pipe = Pipe()
				p.standardOutput = pipe
				
				p.launch()
				p.waitUntilExit()
				
				guard let data = try pipe.fileHandleForReading.readToEnd() else {
					throw SimpleError(message: "Did not get any data from fluxctl")
				}
				
				let images = try JSONDecoder().decode([FluxImage].self, from: data)
				guard images.count == 1, let image = images.first, image.id == workloadID else {
					throw SimpleError(message: "Internal error: Asked for a specific workload id, but got more than one image for this workload. Which means either Flux has a bug, or I did not understand the model it uses.")
				}
				
				DispatchQueue.main.sync{
					self.containers = .success(image.containers)
				}
			} catch {
				DispatchQueue.main.sync{
					self.containers = .failure(error)
				}
			}
		}
	}
	
	private var isLoading = false
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".containers-fetch-queue")
	
}
