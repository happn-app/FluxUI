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
	
	var fluxURL: String
	
	@Published var workloads = Result<[FluxWorkload], Error>.success([])
	
	init(fluxURL url: String) {
		fluxURL = url
	}
	
	func load() {
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
				p.arguments = ["--url", self.fluxURL, "--output-format", "json", "list-workloads", "--namespace", "happn-console"]
				
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
