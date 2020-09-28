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

import Alamofire



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
			
			AF.request(fluxSettings.url.appendingPathComponent("v10").appendingPathComponent("images"), parameters: ["containerFields": "", "namespace": "", "service": workloadID])
				.responseDecodable(of: [FluxImage].self, queue: self.loadQueue){ response in
					let ret: Result<[FluxContainer], Error> = response.result.flatMapError{ .failure($0 as Error) }.flatMap{ images in
						guard images.count == 1, let image = images.first, image.id == workloadID else {
							return .failure(SimpleError(message: "Internal error: Asked for a specific workload id, but got more than one image for this workload. Which means either Flux has a bug, or I did not understand the model it uses."))
						}
						return .success(image.containers)
					}
					DispatchQueue.main.sync{
						self.containers = ret
					}
					self.isLoading = false
				}
		}
	}
	
	private var isLoading = false
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".containers-fetch-queue")
	
}
