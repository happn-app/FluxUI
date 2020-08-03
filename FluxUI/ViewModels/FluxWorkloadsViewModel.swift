/*
 * FluxWorkloadsViewModel.swift
 * FluxUI
 *
 * Created by François Lamboley on 02/08/2020.
 */

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
				p.arguments = ["--url", fluxSettings.url.absoluteString, "--output-format", "json", "list-workloads", "--namespace", fluxSettings.namespace]
				
				let pipe = Pipe()
				p.standardOutput = pipe
				
				p.launch()
				p.waitUntilExit()
				
				guard let data = try pipe.fileHandleForReading.readToEnd() else {
					throw SimpleError(message: "Did not get any data from fluxctl")
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
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".workload-fetch-queue")
	
}
