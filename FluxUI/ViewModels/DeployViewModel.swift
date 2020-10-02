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

import Alamofire



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
		
		updateManifestAndWaitForSuccess(fluxURL: fluxSettings.url, handler: { result in
			switch result {
				case .failure(let e):
					self.failDeployment(e)
					
				case .success:
					let manifestUpdateParams = UpdateManifestData(
						type: .image,
						cause: UpdateManifestData.Cause(Message: "", User: "FluxUI <flux-ui@happn.com>"),
						spec: UpdateManifestData.Spec(ServiceSpec: [workloadID], ImageSpec: containerID, Kind: "execute", Force: false)
					)
					self.updateManifestAndWaitForSuccess(manifestUpdateParams, fluxURL: fluxSettings.url){ result in
						switch result {
							case .failure(let e):
								self.failDeployment(e)
								
							case .success:
								self.updateManifestAndWaitForSuccess(fluxURL: fluxSettings.url){ result in
									DispatchQueue.main.sync{
										self.deployStatus = .deployed(result)
									}
								}
						}
					}
			}
		})
	}
	
	/** Resets the deployment status to .idle if the status was .deployed. */
	func aknowledgeDeployment() {
		assert(Thread.isMainThread)
		guard case .deployed = deployStatus else {return}
		deployStatus = .idle
	}
	
	private let loadQueue = DispatchQueue(label: Constants.appBundleId + ".deploy-queue")
	
	private struct UpdateManifestData : Encodable {
		enum UpdateType : String, Encodable {
			case sync
			case image
		}
		struct Cause : Encodable {
			/* Too lazy to do the whole encoding key name dance rn (regarding
			 * capitalization). */
			var Message: String = ""
			var User: String = ""
		}
		struct Spec : Encodable {
			var ServiceSpec: [String]?
			var ImageSpec: String?
			var Kind: String?
			var Force: Bool?
			/* There’s also "Excludes":null in the sent object but we try without
			 * because I don’t know its type and we’d need to implement the encode
			 * method to deal with it properly anyway to show the null value. */
		}
		var type: UpdateType
		var cause: Cause
		var spec: Spec
	}
	
	private func updateManifestAndWaitForSuccess(_ parameters: UpdateManifestData = UpdateManifestData(type: .sync, cause: UpdateManifestData.Cause(), spec: UpdateManifestData.Spec()), fluxURL: URL, handler: @escaping (_ result: Result<Void, Error>) -> Void) {
		AF.request(fluxURL.appendingPathComponent("v9").appendingPathComponent("update-manifests"), method: .post, parameters: parameters, encoder: JSONParameterEncoder())
			.responseDecodable(of: String.self, queue: self.loadQueue){ response in
				switch response.result {
					case .success(let id):    return self.waitForTaskSuccess(id, fluxURL: fluxURL, handler: handler)
					case .failure(let error): return handler(.failure(error))
				}
			}
	}
	
	private func waitForTaskSuccess(_ id: String, fluxURL: URL, handler: @escaping (_ result: Result<Void, Error>) -> Void) {
		struct JobsResult : Decodable {
			var Err: String
			var StatusString: String
			/* There actually are other properties. */
		}
		AF.request(fluxURL.appendingPathComponent("v6").appendingPathComponent("jobs"), parameters: ["id": id])
			.responseDecodable(of: JobsResult.self, queue: self.loadQueue){ response in
				switch response.result {
					case .success(let result):
						switch result.StatusString {
							case "running", "queued": return self.waitForTaskSuccess(id, fluxURL: fluxURL, handler: handler)
							case "succeeded":         return handler(.success(()))
							default:                  return handler(.failure(SimpleError(message: "Unknown job status \"\(result.StatusString)\". Err = \"\(result.Err)\".")))
						}
						
					case .failure(let error):
						return handler(.failure(error))
				}
			}
	}
	
	private func failDeployment(_ error: Error) {
		DispatchQueue.main.sync{
			self.deployStatus = .deployed(.failure(error))
		}
	}
	
}
