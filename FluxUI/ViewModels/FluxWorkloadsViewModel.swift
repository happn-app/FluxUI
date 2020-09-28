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
			
			AF.request(fluxSettings.url.appendingPathComponent("v6").appendingPathComponent("services"), parameters: ["namespace": fluxSettings.namespace])
				.responseDecodable(of: [FluxWorkload].self, queue: self.loadQueue){ response in
					DispatchQueue.main.sync{
						self.workloads = response.result.flatMapError{ .failure($0 as Error) }
					}
					self.isLoading = false
				}
		}
	}
	
	private var isLoading = false
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".workloads-fetch-queue")
	
}
