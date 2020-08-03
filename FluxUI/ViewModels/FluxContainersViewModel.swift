/*
 * FluxContainersViewModel.swift
 * FluxUI
 *
 * Created by François Lamboley on 03/08/2020.
 */

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
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".workload-fetch-queue")
	
}
