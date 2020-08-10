/*
 * DeployViewModel.swift
 * FluxUI
 *
 * Created by François Lamboley on 05/08/2020.
 */

import Combine
import Foundation



class DeployViewModel : ObservableObject {
	
	enum DeployStatus {
		
		case idle
		case deploying
		case deployed(Result<Void, Error>)
		
		var isIdle: Bool {
			if case .idle = self {return true}
			return false
		}
		
	}
	
	@Published
	private(set) var deployStatus = DeployStatus.idle
	
	let fluxSettings: FluxSettings?
	let workloadID: String
	
	init(fluxSettings: FluxSettings?, workloadID: String) {
		self.fluxSettings = fluxSettings
		self.workloadID = workloadID
	}
	
	func deploy(containerID: String) {
		assert(Thread.isMainThread)
		
		guard case .idle = deployStatus else {return}
		deployStatus = .deploying
		
		guard let fluxSettings = fluxSettings else {
			deployStatus = .deployed(.failure(SimpleError(message: "No Flux settings.")))
			return
		}
		let workloadID = self.workloadID
		
		loadQueue.async{
			do {
				guard let executableURL = Bundle(for: type(of: self)).url(forAuxiliaryExecutable: "fluxctl") else {
					throw SimpleError(message: "Internal error: Cannot find fluxctl, which is annoying because it should be built-in FluxUI!")
				}
				
				let p = Process()
				p.executableURL = executableURL
				p.arguments = ["--url", fluxSettings.url.absoluteString, "release", "--watch", "--namespace", fluxSettings.namespace, "--workload", workloadID, "--update-image", containerID]
				
				let pipe = Pipe()
				p.standardInput = nil
				p.standardOutput = pipe
				p.standardError = pipe
				
				p.launch()
				p.waitUntilExit()
				
				let output = (try? pipe.fileHandleForReading.readToEnd()).flatMap{ String(data: $0, encoding: .utf8) }
				guard p.terminationStatus == 0 else {
					throw SimpleError(message: "fluxctl exited with a error code \(p.terminationStatus). fluxctl output: \(output ?? "<no output, or invalid utf8>")")
				}
				DispatchQueue.main.sync{
					self.deployStatus = .deployed(.success(()))
				}
			} catch {
				DispatchQueue.main.sync{
					self.deployStatus = .deployed(.failure(error))
				}
			}
		}
	}
	
	/** Resets the deployment status to .idle if the status was .deployed. */
	func aknowledgeDeployment() {
		assert(Thread.isMainThread)
		guard case .deployed = deployStatus else {return}
		deployStatus = .idle
	}
	
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".deploy-queue")
	
}
